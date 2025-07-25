

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inscribevs/authentication/data_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inscribevs/components/inscribe_post.dart';
import 'package:inscribevs/components/login/elevated_button.dart';
import 'package:inscribevs/model/profileModel.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:inscribevs/globals.dart' as globals;
// import 'package:inscribevs/components/top_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int follower_count = 0;
  int following_count = 0;
  List followers = [];
  List following = [];
  int _page = 1;
  int _limit = 10;
  bool _firstLoadingRunning = false;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;
  List posts = [];
  bool circular = true;
  bool loading = true;
  final secureStorage = DataService.getInstance;
  ProfileModel profileModel = ProfileModel();
  final ScrollController scrollController = ScrollController();
   

  @override
   void initState() {

    setState(() {
      
    });

    super.initState();
    _getUserInfo();
    _getFollowers();
    _getFollowing();
    fetchUserPosts();
    // _getPostsFirst();
    // _controller = ScrollController()..addListener(_loadMorePosts);
    scrollController.addListener(_scrollListener);
   }


   Future <void> _scrollListener() async{
    if(_isLoadingMore) return;
    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {

      print("call");
      setState(() {
        _isLoadingMore = true;
      });
      _page = _page + 1;
      await fetchUserPosts();
      setState(() {
        _isLoadingMore = false;
      });

    } 
   }


    Future<void> fetchUserPosts() async {

      String token = await secureStorage.read('token');
      var decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];

      String URL = '${globals.base_url}/users/${userId}/posts';

      final response = await http.get(
        Uri.parse("$URL?page=$_page&limit$_limit"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {

        final responseData = json.decode(response.body);
        print("\n ResponseData: ${responseData} \n");
        final postsData = responseData["data"];
        print("\n PostsData: ${postsData} \n");
        setState(() {
          posts = posts + postsData["posts"];
          if (_page == postsData["pages"])
          {
            _hasMorePages = false;
          }
        print("\n Post List: ${posts} \n");
        });
      } else {
        print("\n Unable to fetch posts: \n ${response.body}\n");
      }
      

    }



    void _getUserInfo() async{
      setState(() {
        _firstLoadingRunning = true;
      });

      String token = await secureStorage.read('token');
      var decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];
      
      print("User ID: ${userId}");
      String URL = '${globals.base_url}/users/${userId}';

      final response = await http.get(
        Uri.parse(URL),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {

        final responseData = jsonDecode(response.body);
        setState(() {
         profileModel = ProfileModel.fromJson(responseData["data"]);
          circular = false;
        });
      
        print("Grabbing user info successful: ${responseData}");
      }
      else {
        print("Grabbing user info unsuccessful: ${response.body}"); 
      }
      
  }



  void _getFollowers() async {

     String token = await secureStorage.read('token');
      var decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];

      String URL = '${globals.base_url}/users/${userId}/followers';

      final response = await http.get(
      Uri.parse("$URL?page=$_page&limit$_limit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
        },
      );

      final responseData = jsonDecode(response.body);
      final postList = responseData["data"];
      setState(() {
        posts = postList;
        print("List of Posts: ${posts}");
      });

    } catch (error) {
      if (kDebugMode) {
        print("Something went wrong");
      }
    }

    setState(() {
      _firstLoadingRunning = false;
    });
    
  }



    void _loadMorePosts() async {
      String token = await secureStorage.read('token');

      const String URL = 'https://inscribed-22337aee4c1b.herokuapp.com/api/user/get-posts';
      if (_hasNextPage == true &&
        _firstLoadingRunning == false && _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300
        ) {

            setState(() {
              _isLoadMoreRunning = true;
            });

          _page += 1;

          try {
            final response = await http.get(
            Uri.parse("$URL?page=$_page&limit$_limit"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
              },
            );

            final responseData = jsonDecode(response.body);
            final postList = responseData["data"] as List;

            if (postList.isNotEmpty) {
              setState(() {
              posts.addAll(postList);
              //print("List of Posts: ${posts}");
              });
            } else {
              setState(() {
                _hasNextPage = false;
              });
            }
           

          } catch (error) {
            if (kDebugMode) {
              print("${error}");
            }
          }
          

            setState(() {
              _isLoadMoreRunning = false;
            });
      }
  }
   
  @override
  Widget build(BuildContext context) {
  
    return circular?SizedBox(height: MediaQuery.of(context).size.height / 1.3, child: Center(child: CircularProgressIndicator())):Scaffold(
       floatingActionButton: FloatingActionButton.small(
          backgroundColor: const Color.fromRGBO(82, 183, 136, 1),
          onPressed: (){
             Navigator.pushNamed(context, '/newpostpage').then((_) => setState(() {}));
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),   
      backgroundColor: const Color.fromARGB(255, 216, 243, 220),
      body: SafeArea(
        
        // appBar: TopBar(title: '${profileModel.username}'),
        child:SingleChildScrollView(
          
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                color: const Color.fromARGB(255, 216, 243, 220),
                child: Column (
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Profile 
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.indigoAccent,
                      ),
                      InkWell(
                       onTap: () {},
                       child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red, 
                          child: Icon(
                            Icons.edit,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                     )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "${profileModel.first_name} ${profileModel.last_name}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                        
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                    child: Text(
                      "${profileModel.email}",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400
                      ),  
                    ),
                  ),
                  // Profile Bio
                  
                    Text(
                            '${profileModel.bio}',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300
                            )
                          ),
                        
                  Row (
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          //// Followers Button
                        // ToDo Implement Followers List
                          Text(
                            "${follower_count}",
                             style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: 2),
                          
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300
                            )
                          ),
                        ],
                      ),
                        // Following Button
                        // ToDo Implement Following Users List
                        Column(
                        children: [
                          Text(
                            "${following_count}",
                           style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: 2),
                          
                          Text(
                            'Following',
                             style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300
                            )
                          ),
                        ],
                      ),
                    ],
                    ),
                    // Update Bio Button
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButtonWithoutIcon(
                        labelText: 'Update Profile', 
                        onPressed: () {
                          // Update Profile
                          Navigator.pushNamed(context, '/changebiopage');
                        }),
                    ),
                  
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          
                      // Posts Title
                      child: Text(
                        'Posts',
                          style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold
                          )
                        ),
                    ),
                   
                    const SizedBox(height: 12),
                     // List view or Posts
                     
                  //  _firstLoadingRunning? const Center(
                  //     child: CircularProgressIndicator()): 
                  
                  
                  Column(children: [
                              
                    //Lists of Posts in form of Cards    
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _isLoadingMore ? posts.length + 1 : posts.length,
                      itemBuilder: (_, index) {
                        if (index < posts.length) {
                          return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: InscribePost(updateStartPage: () {setState(() {
                            
                          });},username: posts[index]['username'], postId: posts[index]['_id'], num_of_likes: posts[index]['likesCount'], post_content: posts[index]['content'])
                         
                         );
                        } else {
                          return Center(child: CircularProgressIndicator(),);
                        }
                      },
                     
                    ),
                    // // Loading indicator for the posts
                    // if (_isLoadMoreRunning == true)
                    //   const Padding(
                    //     padding: EdgeInsets.only(top: 10, bottom: 40),
                    //     child: Center(
                    //       child: CircularProgressIndicator.adaptive(),
                    //     ),
                    //   ),
                    
                    // // If there are no more pages to loa
                  
                  ],
                  ),
                ],
                ),
              ),
            ),
          ),
        ) ,
      ),
    );
  }
}
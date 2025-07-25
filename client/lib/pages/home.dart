import 'package:flutter/material.dart';
import 'package:inscribevs/model/postModel.dart';
import 'package:inscribevs/authentication/data_service.dart';
import 'package:inscribevs/post.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inscribevs/authentication/data_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}



class _UserHomeState extends State<UserHome> {
  //GET THE USER ID
  //THE USER ID  IS USED TO RETRIEVE THE POSTS OF THE PEOPLE
  //THAT USER FOLLOWS TO BE DISPLAYED ON HOME SCREEN
  //REQ.PAGE
  //REQ.LIMIT
  //req: Request, res: Response
  //enter home pgae
  //we need to retrieve the posts of the people we follow
  //we have to access the servery
  //to access the server we have to confirm who we are using id
  //retrieve id and use that as json header
  late Future<List<Post>> futurePosts;
  String id = '';
  List posts = [];
  int currentPage = 1;
  final int limit = 10;
  bool isLoading = false;
  bool hasMore = true;
  bool _firstLoadingRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool circular = true;
  bool loading = true;
  final secureStorage = DataService.getInstance;
  //Post postModel = Post(id: id, content: content, createdAt: createdAt, user: user);

  @override
  void initState() {


    super.initState();
    _getInitialPosts();
    //fetchInitialPosts();
  }



  
Future<void> _getInitialPosts() async{

    if(isLoading || !hasMore) return;


     setState(() {
        isLoading = true;
        _firstLoadingRunning = true;
      });

    String token = await secureStorage.read('token');
    const String URL = 'https://inscribed-22337aee4c1b.herokuapp.com/api/users/for-you-feed';

  try{
      final response = await http.get(
      Uri.parse("$URL?page=$currentPage&limit$limit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        
        final responseData = jsonDecode(response.body);
        final postList = responseData["data"];
        if (responseData == null) {
          setState(() {
            hasMore = false;
          });
        }
        setState(() {
          posts = postList;
          print("List of Posts: ${posts}");
          //postModel = postModel.PostFromJson(responseData["data"]);
          //circular = false;
        });
      
          List<Post> fetchedPosts = responseData.map((post) => Post.fromJson(post)).toList();
          setState(() {
            currentPage++;
            isLoading = false;
            if (fetchedPosts.length < limit) {
              hasMore = false;
            }
            posts.addAll(fetchedPosts);
          });
        }
        //print("Grabbing user info successful: ${responseData}");
        else{
          throw Exception('Failed to load posts');
        }
      }
       catch (e) {
        print('Error during fetching posts: $e');
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      _firstLoadingRunning = false;
    });
  }
  /*
  void _getUserInfo() async {

    String token = await secureStorage.read('token');
    //API endpoint URL
    const String URL = 'https://inscribed-22337aee4c1b.herokuapp.com/api/users/for-you-feed';

    try{
        final response = await http.get(
          Uri.parse(URL),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
          );

        if (response.statusCode == 200) {

          final responseData = jsonDecode(response.body);
          setState(() {
            //postModel = Post.fromJson(responseData['data']);
          });
         // List jsonResponse = json.decode(response.body)['data']['posts'];
          //return jsonResponse.map((post) => Post.fromJson(post)).toList();

        } else {

          throw Exception('Failed to load posts');
        }
      } catch(e){

        print('Error during fetching posts: $e');
        throw Exception('Failed to load posts');
      }
  }*/

/*
  Future<void> fetchInitialPosts() async {
    futurePosts = fetchPosts();
    List<Post> initialPosts = await futurePosts;
    setState(() {
      posts = initialPosts;
    });
  }

  Future<void> fetchMorePosts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      List morePosts = await fetchPosts();
      setState(() {
        currentPage++;
        isLoading = false;
        if (morePosts.length < limit) {
          hasMore = false;
        }
        posts.addAll(morePosts);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error during fetching more posts: $e');
    }
  }
  */

  /*var Info; 
  void initState() {

    setState(() {
      
    });
    //  _getDecodedToken();
    super.initState();
   
    // _getPostsFirst();
    // _controller = ScrollController()..addListener(_loadMorePosts);
    
   }*/
  
  // Future <void> _getDecodedToken() async{
  //   // final secureStorage = DataService.getInstance;
  //   // String token = await secureStorage.read('token');
  //   // Info = JwtDecoder.decode(token);
  //   // String userId = Info['userId'];
  //   // print("Info is ${Info}");
  //   // print("UserId is ${userId}");
  // }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 243, 220),
      appBar: AppBar(
        title: Text('Inscribe'),
        backgroundColor: Color.fromARGB(255, 216, 243, 220),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !isLoading) {
            _getInitialPosts();
          }
          return true;
        },
        child: ListView.builder(
          itemCount: posts.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return Center(child: CircularProgressIndicator());
            }
            Post post = posts[index];
            return ListTile(
              title: Text(post.content ?? 'No content'),
              subtitle: Text(post.user.username ?? 'Anonymous'),
              trailing: Text(post.createdAt?.toLocal().toString() ?? 'No date'),
            );
          },
        ),
      ),
    /*  body: FutureBuilder<List<Post>>(
        future: futurePosts,
         builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No posts available'));
            } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                return ListTile(
                  title: Text(post.content),
                  subtitle: Text(post.user.username),
                  trailing: Text(post.createdAt.toLocal().toString()),
                );
              },
            );
         }
       }
     ),*/
     floatingActionButton: FloatingActionButton.small(
          backgroundColor: const Color.fromRGBO(82, 183, 136, 1),
          onPressed: (){
             Navigator.pushNamed(context, '/newpostpage').then((_) => setState(() {}));
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),   
      
      //body: Center(
     // child: Text(
     //   'Home'
        );
    
    
  }
}
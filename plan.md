# Robosolver Plan

## Front end
- Elm App
  - [x] Basic Wall/Cell Definition
  - [x] Clear walls action
  - [x] Different Cell Types
    - robot home
    - destination
    - both?
  - [ ] Serialization (encode)
    - [x] first to JSON
    - [ ] save in localstorage
    - [ ] then send to server woo
  - [ ] Deserialization
    - [x] write deserializer
    - [ ] persist to local storage as a test
  - [ ] Server involvement
    - [ ] persist state to server (learn elm/http)
    - [ ] solve on server
      - [ ] generic function for adjacency matrix of a gameboard
      - [ ] solver output
      - [ ] start w/o searching other robots' moves
      - [ ] incorporate possible other robot moves
        - simple strategy; search all sets of other robot moves < min path w/o moves
    - [ ] pass server solutions back to client
  - [ ] Display solutions in client
    - maybe just start with colored arrow unicodes for paths
    - possibly / probably take a list of moves, and step through them


## Back end

### Solving
- [ ] Implement some search algorithms
  - [x] BFS
  - [ ] A*

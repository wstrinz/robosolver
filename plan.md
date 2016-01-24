# Robosolver Plan

## Front end
- Elm App
  - [x] Basic Wall/Cell Definition
  - [x] Clear walls action
  - [x] Different Cell Types
    - robot home
    - destination
    - both?
  - [x] Serialization (encode)
    - [x] first to JSON
    - [x] save in localstorage
    - [ ] then send to server woo
  - [x] Deserialization
    - [x] write deserializer
    - [x] persist to local storage as a test
  - [ ] Server involvement
    - [ ] persist state to server (learn elm/http or just ports)
    - [ ] computer neighbors/adjacency matrix
    - [ ] solve on server
      - [ ] generic function for adjacency matrix of a gameboard
      - [ ] solver output
      - [ ] start w/o searching other robots' moves
      - [ ] incorporate possible other robot moves
        - simple strategy; search all sets of other robot moves < min path w/o moves
    - [ ] pass server solutions back to client
  - [ ] Spruce up client
    - code cleanup
    - fix inability to unset robits/add new ones
    - Better colors
    - fid a nice way of tokens and space types being next to each other
  - [ ] Display solutions in client
    - maybe just start with colored arrow unicodes for paths
    - possibly / probably take a list of moves, and step through them


## Back end

### Solving
- [ ] Implement some search algorithms
  - [x] BFS
  - [ ] A*

## Ideas / misc todo
- [ ] Use Dict structure for cells b/c listof lists is stupid
- [ ] Show save / load all the time
- [ ] fix green robot
- [ ] show/hide model output button
- [ ] Build a "show moveable spaces from space" function; you've got the data and the ability to display stuff...
- [ ] nicer walls
- [ ] different default BG?

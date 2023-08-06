# MailPlug <img src="https://github.com/elisha0103/MailPlug/assets/41459466/01ed7f71-6a5a-446c-afaf-03728d7e1b95" width="25" height="25">

> 프로젝트 목표에 맞춰 메일플러그 게시판 화면 그리는 프로젝트

<br>

<img src="https://github.com/elisha0103/MailPlug/assets/41459466/a52d478a-eaf7-460d-8baa-e15608783ef8">

<br>

## 프로젝트 목표
> - **Codebase로 프로젝트 작성**
> - **선택된 게시판별로 게시글 API 요청하기**
> - **요청된 게시글 데이터 Pagination 기능 구현하기**
> - **검색 내역, 검색 결과 데이터 유무에 따른 화면 노출하기**
> - **검색어 입력시 키워드별로 필터링된 게시글 API 요청하기**
> - **검색 내역을 저장해 결과 내역을 보여주기**

<br>

## 구현한 기능
 - Alamofire 사용하여 게시판, 게시글, 검색 데이터 API 요청
 - 검색 키워드에 따른 검색 데이터에 키워드와 동일한 제목, 작성자 **문자열 강조 표시**
 - 게시판별 Pagination 기능 도입으로 시스템 안정성, 사용자 경험 개선
 - Combine으로 데이터 바인딩을 통해 즉각적인 반응형 View 구성
 - 검색 결과 유무에 따른 백그라운드 이미지 구성
 - SearchTextField와 Cancel 버튼 추적하여 하위에 보여지는 UITableView 전환(검색 결과 화면에서 검색 키워드 화면으로 전환 기능)

<br>

## 개발 환경
- Language: Swift
- Deployment Target: iOS 14.0
- Architecture: MVVM
- 프레임워크: UIKit - Codebase
- Third Party: Alamofire

<br>
<br>

# 폴더 컨벤션

```
MailPlug
├── AppFiles
├── Model
├── Protocol
├── Extension
├── View
│   ├── BoardView
│   ├── ModalBoardsView 
│   └── PostSearchView  
├── ViewModel
│   ├── BoardViewModel
│   ├── ModalBoardsViewModel
│   └── SearchPostViewModel
├── Utils
└── API

```


# 목차
- [프로젝트 특징](#프로젝트-특징)
- [구현 화면](#구현-화면)
- [보완할 사항](#보완할-사항)

<br>
<br>

# 프로젝트 특징
## 1. 게시판
### 1-1 게시판의 데이터 바인딩
- ViewModel에서 전체 게시판 API 호출을 하고 selectedBoard 변수에 하나의 게시판을 할당한다.
- ViewModel에서 selectedBoard를 할당하는 방법은 초기 한번, ModalView로 게시판을 선택할 때 Delegate 패턴으로 할당한다.
- View에서는 ViewModel의 selectedBoard 변수를 바인딩하여 Navigation Title에 해당 게시판 이름으로 보여준다.

```swift
        self.viewModel.$selectedBoard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] board in
                self?.navigationItem.title = board.displayName
                
            }
            .store(in: &cancelBag)
```
<br>

- ModalView에서 게시판을 선택 할 때 선택된 게시판을 상위 ViewController에게 전달하는 방법으로 Delegate 패턴을 사용한다.

```swift
extension BoardViewController: ModalBoardsDelegate {
    func didSelectedBoard(_ board: Board) {
        self.viewModel.selectedBoard = board
        self.viewModel.offset = 0
    }
}
```

- 선택된 게시판에 있는 게시글을 보여줄 때에는 View에서 ViewModel의 currentPosts를 데이터 바인딩한다.
- currentPosts에 데이터를 할당하는 경우는 ViewModel에 fetchPosts 함수가 실행되는 경우이고, fetchPosts은 ViewModel에서 offset 값이 변경되면 자동 실행된다.
    - 즉, Delegate 패턴으로 ModalView에서 selectedBoard 값을 새로 할당하면 ViewModel의 offset 값은 자동으로 0 값을 할당한다. 
    - offset 값이 0으로 변경 됨에 따라 바인딩하고 있는 fetchPosts가 offset 값과 selectedBoard 값을 기반으로 currentPosts가 최신으로 변경된다.
    - ViewModel의 currentPosts를 바인딩하는 tableView는 새로운 값으로 reloadData() 함수를 실행하여 View에 반영한다.
    - currentPosts가 없는 경우에는 게시판의 게시글이 없다는 배경화면을 보여준다.

<br>

### 1-2 게시글의 Pagination
- UITableView에 내장되어있는 scrollViewDidScroll 함수를 사용하여 Pagination 기능 구현

```swift
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = tableView.contentOffset.y
        let tableViewContentSize = tableView.contentSize.height
        
        if viewModel.posts.post.isEmpty && viewModel.offset == 0 { return }
        
        if contentOffsetY > (tableViewContentSize - tableView.bounds.size.height),
           viewModel.isPaginationFetching, contentOffsetY > 0 {
            viewModel.isPaginationFetching = false
            viewModel.offset += 30
        }
    }
```

- tableView의 Height 값을 구해서 화면이 tableView 가장 아래에 위치한 경우 offset 값을 증가하여 ViewModel의 fetchPosts 함수를 실행한다.
- 처음 View가 Load된 경우, 파일의 끝으로 더이상 서버로부터 가져올 데이터가 더이상 없는 경우 등을 분기처리하여 구현

<br>

### 1-3 Date 설정
- 게시글의 게시 날짜가 현재 날짜와 동일한지 확인하여 새로운 게시글 Badge, 날짜 표현 형식을 다르게 함

```swift
extension Date {    
    func isSameDay(_ date: Date) -> Bool {
        let firstFomatter = DateFormatter()
        firstFomatter.locale = Locale(identifier: Locale.current.identifier)
        
        let secondFomatter = DateFormatter()
        secondFomatter.locale = Locale(identifier: Locale.current.identifier)
        
        firstFomatter.dateFormat = "yyyy-MM-dd"
        secondFomatter.dateFormat = "yyyy-MM-dd"
        return firstFomatter.string(from: date) == secondFomatter.string(from: Date())
    }
}

```

- Date 타입에 extension을 하여 self와 현재 날짜가 일치하는지 확인하여 반환하는 함수를 사용하여 Badge 표시 여부, 날짜 표현 방식을 다르게 함.
    - 게시글의 게시 날짜와 현재 날짜가 같다면 게시글 좌측 끝에 새로운 게시글이라는 이미지 표시
    - 게시글의 게시 날짜와 현재 날짜가 같다면 날짜 포맷을 "yy-MM-dd" 에서 "h:m"로 표현 **(디자인 가이드라인 참고)**

<br>
<br>

## 2. 검색
- 검색어 입력시 카테고리별로 선택할 수 있는 UITableViewCell이 나타난다.
- Cell을 선택하면 선택된 게시판 정보와 카테고리, 검색어를 기반으로 네트워크 API 호출하여 게시글 데이터를 받아온다.

### 2-1 데이터 바인딩
- ViewModel의 searchResults를 바인딩하여 searchResults의 값으로 키워드 + 검색어 텍스트를 보여주는 UITableViewCell을 핸들링
    - searchResults 값이 없는 경우 -> 검색 요청을 하지 않은 경우이기 때문에 입력된 검색어에 대한 카테고리 cell들을 보여주는 UITableView가 나타남
    - searchResults 값이 없는 경우 -> 검색어 TextField 값도 없는 경우 -> UITableView 배경화면으로 검색어 입력 요청 이미지 보여줌

- ViewModel의 isEmpty를 바인딩하여 키워드 + 검색어로 네트워크 API 요청한 데이터를 보여주는 UITableViewCell을 핸들링
    - isEmpty 값이 true인 경우 -> 검색 요청 결과, 검색 결과가 없다는 이미지를 UITableView 배경화면으로 보여줌
    - isEmpty 값이 false인 경우 -> 검색 게시글 cell을 보여주는 UITableView가 나타남

<br>

### 2-2 검색 결과, 검색어와 일치하는 텍스트 강조 표시
- 검색된 게시글 데이터에서 검색어와 일치하는 제목, 작성자 문자열이 강조표시 됨

```swift
    func searchStringAttributedString(_ string: String) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(string: string)
        let entireLength = string.count
        var range = NSRange(location: 0, length: entireLength)
        var rangeArr = [NSRange]()
        
        while range.location != NSNotFound {
            
            range = (attrStr.string as NSString).range(of: searchString ?? "", options: .caseInsensitive, range: range)
            rangeArr.append(range)

            if range.location != NSNotFound {
                range = NSRange(location: range.location + range.length,
                                length: string.count - (range.location + range.length))
                
            }
            
        }
        rangeArr.forEach { range in
            attrStr.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
            
        }
        return attrStr

    }
```

- BoardTableCellViewModel에 있는 searchStringAttributedString 함수를 사용하여 title, writer의 attributedText 값을 변경함
- 전체 문자열을 반복문으로 하나씩 Character로 반환하여 검색어 Character와 비교하여 일치하는 문자열을 attrStr에 추가한 후 새로운 속성을 할당하여 반환한다.

<br>
<br>


# 구현 화면
<div align="center">

|<img src="https://github.com/elisha0103/MailPlug/assets/41459466/b7e814f1-3c66-4352-8520-79c4b60488a4" width="200">|<img src="https://github.com/elisha0103/MailPlug/assets/41459466/b730fb89-f662-4af1-b853-30a3ab8c8ee6" width="200">|
|:-:|:-:|
|게시판 선택|게시글 검색|



</div>

<br>
<br>

# 보완할 사항
### 1. PostSearchController의 Cell 핸들링
- PostSearchController의 하나의 UITableView에 두 타입의 UITableViewCell을 사용한다.
    - UITableViewDataSource에서 서로 다른 두 타입의 UITableViewCell을 분기처리 하여 핸들링하는데, 기능이나 코드를 캡슐화하지 않아서 유지보수의 어려움 발생
    ```swift
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.searchResults.searchResult.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: postSearchTableViewCell,
                                                     for: indexPath) as? PostSearchTableViewCell
            
            guard let cell = cell else { fatalError("PostSearchTableView Cell Error") }
            let category = SearchCategory(rawValue: indexPath.row)
            guard let category = category else { fatalError("PostSearchTableView Cell Error") }
            
            cell.category = category
            cell.searchStringLabel.text = self.searchString
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchResultTableViewCell,
                                                 for: indexPath) as? BoardTableViewCell
        
        guard let cell = cell else { fatalError("searchResultTableViewCell Cell Error") }

        let post = viewModel.searchResults.searchResult[indexPath.row]
        cell.viewModel = BoardTableCellViewModel(post: post, searchString: searchString)
        return cell
    }
    ```
    - **해결 가능 방안**: UITableViewCell의 기능적 요소를 Cell 클래스 안에 작성하고, 분기처리 기능을 캡슐화하여 가독성, 유지보수성을 고려한 코드로 리팩토링 진행

<br>

### 2. PostSearchController의 검색 입력, 검색 결과 유/무에 따른 화면 출력
- SearchController의 검색어 입력 여부와 검색 결과 유/무에 따른 화면 출력을 하나의 UITableView에서 진행하다보니 이에 대한 분기처리가 상당히 복잡함
    ```swift
            self.viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchResults in
                if searchResults.searchResult.isEmpty {
                    self?.tableView.rowHeight = 45
                    self?.tableView.separatorStyle = .singleLine
                    
                    self?.tableView.backgroundView = self?.noneHistoryStackView
                    self?.tableView.backgroundView?.setDimensions(width: 250, height: 240)
                    self?.tableView.backgroundView?.centerX(inView: (self?.tableView)!,
                                                            topAnchor: (self?.tableView)!.topAnchor, paddingTop: 200)

                    self?.searchString.isEmpty ?? true ?
                    (self?.tableView.backgroundView?.isHidden = false) :
                    (self?.tableView.backgroundView?.isHidden = true)
                    
                } else {
                    self?.tableView.rowHeight = 74
                    self?.tableView.separatorStyle = .none
                    
                }
                
                self?.tableView.reloadData()
            }
            .store(in: &cancelBag)
        
        self.viewModel.$isEmptyData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.tableView.backgroundView = self?.noneSearchStackView
                    self?.tableView.backgroundView?.setDimensions(width: 250, height: 240)
                    self?.tableView.backgroundView?.centerX(inView: (self?.tableView)!,
                                                            topAnchor: (self?.tableView)!.topAnchor, paddingTop: 200)
                    
                    self?.tableView.backgroundView?.isHidden = false
                }
            }
            .store(in: &cancelBag)
    ```

    - **해결 가능 방안**: UITableView를 하나의 인스턴스로 하지 않고, 두 개의 인스턴스로 분리하여 처리하는 방법으로 리팩토링 진행

<br>

### 3. 검색 결과에 따른 검색 History LocalDB 저장
- 검색 결과를 LocalDB에 저장하고 SearchController의 SearchTextField가 포커싱될 때 검색 History 데이터를 UITableViewCell로 출력하기
- 기기에서의 검색 결과이기 때문에 History 데이터를 LocalDB에 저장
- ___시간 제한상 기능 구현 불가___
- **해결 가능 방안**: CoreData로 각 Enity 설정하여 기기에 데이터 저장하고, SearchViewController가 로드될 때, CoreData의 History 데이터 Fetch하여 Cell로 데이터 정보 출력

<br>
<br>

## 참고사항
<details>
<summary>코드 컨벤션</summary>
<div markdown="1">

- Swiftlint 적용

- 네이밍
    - 일반변수 / 상수인 경우 따로 접두사를 붙이지 않는다.
    - enum case는 대문자로 시작한다.
    - 일반적인 부분이 앞에, 구체적인 부분을 뒤에 둬 모호함을 없앤다.
    - 클래스 함수에는 되도록 get을 붙이지 않는다.
    - 액션 함수는 ‘주어 + 동사 + 목적어’ 형태를 사용한다.
    - 약어로 시작하는 경우 소문자로 표기하고, 그 외 경우에는 항상 대문자로 표기한다.    
    - 디자인 컨셉을 통일하고 진행했으면 전체적인 디자인을 구성하는데 효율적일거 같다.
    
- 기타
    - 클로저 정의시 파라미터에는 괄호를 사용하지 않는다.
    - 클로저 정의시 가능한 경우 타입 정의를 생략한다.
    - 사용하지 않는 파라미터는 삭제하거나 _를 사용해 표시한다.
    - 구조체 생성시 Swift 구조체 생성자를 사용한다.
    - Array<T>, Dictionary<T: U> 보다는 [T], [T: U]를 사용한다.
    - 언어에서 필수로 요구하지 않는 이상 self는 사용하지 않는다.
    - 프로퍼티의 초기화는 가능하면 init에서 하고, unwrapped Optional의 사용을 지양한다.
    - 더이상 상속이 발생하지 않는 클래스는 항상 final 키워드로 선언한다.
    - switch - case 에서 가능한 경우 default를 사용하지 않는다.
    - return은 사용하지 않는다.
    - 사용하지 않는 코드는 주석 포함 모두 삭제한다.

</div>
</details>

    
## 활용기술

#### Platforms

<img src="https://img.shields.io/badge/iOS-5A29E4?style=flat&logo=iOS&logoColor=white"/>  

<br>

#### Language & Tools

<img src="https://img.shields.io/badge/Xcode-147EFB?style=flat&logo=Xcode&logoColor=white"/> <img src="https://img.shields.io/badge/UIKit-%232396F3.svg?&style=flat&logo=UIKit&logoColor=white" /> <img src="https://img.shields.io/badge/Swift-F05138?style=flat&logo=swift&logoColor=white"/>
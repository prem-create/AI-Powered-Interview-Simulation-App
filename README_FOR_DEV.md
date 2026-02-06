# interview_app

commit **bloc initalize**

- improved file structure
- bloc initalized
- my_custom_card-> width= finite (TODO: make all the hard coded value in proportion with respect to h and w for height and width and sp for pixels)
- [number].ht and [number].wt means height and widget of sized box
- resposive_builder initialized
  ```
    ScreenTypeLayout.builder(
    mobile: (_)=> MobileView(),// for  mobile screen
    tablet: (_)=> TabletView(),// for tablet screen
    desktop: (_) => DesktopView(),// for desktop screen
  );
  ```
- adding an SizedBox Extenstion in lib/core/extensions/

  ```
    use number.ht for SizedBox(height:number)
    example- 20.ht
  
    use number.wt for SizedBox(width:number)
    example- 20.wt
  ```

- adding flutter_screenutil: ^5.9.3
    ```
    for height use .h
    for width use .w
    for padding use .p
    for radius use .r
    ```

//
//  PageViewController.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/15/23.
//

import SwiftUI
import UIKit


struct PageViewController<Page: View>: UIViewControllerRepresentable {
  var pages: [Page]

  func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }

  func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal)

    pageViewController.dataSource = context.coordinator
    return pageViewController
  }


  func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    pageViewController.setViewControllers(
      [context.coordinator.controllers[0]], direction: .forward, animated: true)
  }

  class Coordinator: NSObject, UIPageViewControllerDataSource {
      var parent: PageViewController
      var controllers = [UIViewController]()


      init(_ pageViewController: PageViewController) {
          parent = pageViewController
          controllers = parent.pages.map {
              let hostingController = UIHostingController(rootView: $0)
              hostingController.view.backgroundColor = UIColor.black // Set your desired background color for each page
              return hostingController
          }
      }


      func pageViewController(
          _ pageViewController: UIPageViewController,
          viewControllerBefore viewController: UIViewController) -> UIViewController?
      {
          guard let index = controllers.firstIndex(of: viewController) else {
              return nil
          }
          if index == 0 {
              return controllers.last
          }
          return controllers[index - 1]
      }


      func pageViewController(
          _ pageViewController: UIPageViewController,
          viewControllerAfter viewController: UIViewController) -> UIViewController?
      {
          guard let index = controllers.firstIndex(of: viewController) else {
              return nil
          }
          if index + 1 == controllers.count {
              return controllers.first
          }
          return controllers[index + 1]
      }
  }
}

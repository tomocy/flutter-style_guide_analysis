import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/lint/linter.dart';

class ConstructorsComeFirstInAClass extends LintRule implements NodeLintRule {
  ConstructorsComeFirstInAClass()
      : super(
          name: 'constructors_come_first_in_a_class',
          description: 'Declare constructors before anything else.',
          details: '''
          The default (unnamed) constructor should come first, then the named constructors. They should come before anything else (including, e.g., constants or static methods).

          This helps readers determine whether the class has a default implied constructor or not at a glance. If it was possible for a constructor to be anywhere in the class, then the reader would have to examine every line of the class to determine whether or not there was an implicit constructor or not.
          ''',
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  _Visitor(this.rule);

  static const LintCode code = LintCode(
    'constructors_come_first_in_a_class',
    "The constructor {0} should come first before {1} but doesn't.",
    correction: 'Try moving the constructor before {1}.',
  );

  final LintRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var didVisitNonConstructorMember = false;
    var firstVisitedNonConstructorMember;

    node.members.forEach((member) {
      if (member is! ConstructorDeclaration) {
        didVisitNonConstructorMember = true;
        firstVisitedNonConstructorMember ??= member;
        return;
      }
      if (!didVisitNonConstructorMember) return;

      rule.reportLint(
        member,
        arguments: ["'$member'", "'$firstVisitedNonConstructorMember'"],
        errorCode: code,
      );
    });
  }
}

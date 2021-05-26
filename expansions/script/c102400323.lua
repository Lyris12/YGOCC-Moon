--created & coded by Lyris, art from "Flipping the Table"
--ちゃぶ台返者
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetFieldGroup(p,0,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,1-p,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetFieldGroup(p,0,LOCATION_ONFIELD)
	if Duel.Destroy(g,REASON_EFFECT)~=#g then return end
	Duel.BreakEffect()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_END,1)
	Duel.RegisterEffect(e1,p)
	local ct=#Duel.GetOperatedGroup()
	local tg1=Group.CreateGroup()
	local tg2=Duel.GetMatchingGroup(Card.IsAbleToHand,p,0,LOCATION_GRAVE,nil)
	for i=1,ct do local tg3=tg2:GetMinGroup(Card.GetSequence) tg1:Merge(tg3) tg2:Sub(tg3)
	if i<ct and #tg2==0 then return end end
	Duel.SendtoHand(tg1,nil,REASON_EFFECT)
	Duel.ConfirmCards(p,tg1)
end

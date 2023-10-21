--created by Jake, coded by Lyris
--Crush Cyberse Virus
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(aux.NOT(Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_LINK)
end
function s.cfilter(c,tp)
	return c:IsLinkAbove(1) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(Card.IsLinkAbove,tp,LOCATION_MZONE,0,1,nil,c:GetLink()+1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	e:SetLabelObject(tc)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	local g=Duel.GetMatchingGroup(Card.IsLinkAbove,tp,0,LOCATION_MZONE,nil,e:GetLabelObject():GetLink()+1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.xfilter(c,atk)
	return c:IsType(TYPE_LINK) and and c:GetBaseAttack()>atk and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lc=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(Card.IsLinkAbove,tp,0,LOCATION_MZONE,nil,lc:GetLink()+1)
	if Duel.Destroy(g,REASON_EFFECT)~=#g then return end
	local tg=Duel.GetMatchingGroup(s.xfilter,tp,0,LOCATION_EXTRA,1,nil,lc:GetAttack())
	if #tg>=#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(tg:Select(1-tp,#g,#g,nil),REASON_EFFECT)
	end
end

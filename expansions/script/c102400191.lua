--created & coded by Lyris, art by Nardack
--フェイツ・カオス・ゴッデス
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_TRAP)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
end
function cid.filter1(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
function cid.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xf7a)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(cid.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	local g2=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return #g1>0 and #g2>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,g2:GetCount(),0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(cid.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	local g2=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.SendtoGrave(g2,REASON_EFFECT+REASON_RETURN)
	end
end
--Duelahan Lantern Chops
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),1,1)
	c:EnableReviveLimit()
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cid.atkval)
	c:RegisterEffect(e2)
	--direct atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	--handes
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(cid.tdcon)
	e4:SetCost(cid.tdcost)
	e4:SetTarget(cid.tdtg)
	e4:SetOperation(cid.tdop)
	c:RegisterEffect(e4)
end
function cid.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x684) and c:GetAttack()>=0
end
function cid.atkval(e,c)
	local lg=c:GetLinkedGroup():Filter(cid.atkfilter,nil)
	return lg:GetSum(Card.GetAttack)
end
function cid.indesfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x684)
end
function cid.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetLinkedGroup():IsExists(cid.indesfilter,1,nil)
end
function cid.cfilter(c)
	return c:IsSetCard(0x684) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,cid.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,cid.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	end
end
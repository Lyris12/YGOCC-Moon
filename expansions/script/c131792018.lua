--created by LeonDuvall, coded by Lyris
--Rapid Reformation of Unstable Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd16) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:GetDestination()&LOCATION_DECK+LOCATION_REMOVED>0 and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsDestructable(e)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil,e,tp)
	if chk==0 then return #g>0 end
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:SetLabelObject(g:Clone())
		Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end
function s.cfilter(c,tp,e)
	return c:IsFaceup() and c:IsLevel(5) and c:IsSetCard(0xd16) and Duel.GetMZoneCount(tp,c)>0 and (not e
		or Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalAttribute()))
end
function s.sfilter(c,e,tp,at)
	return c:IsSetCard(0xd16) and c:GetOriginalAttribute()&at==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanTransform(SIDE_REVERSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler() and s.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_MZONE,0,1,nil,tp,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,e),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummonStep(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc:GetOriginalAttribute()),0,tp,tp,false,false,POS_FACEUP)>0 then Duel.Transform(c,SIDE_REVERSE,e,tp) end
	Duel.SpecialSummonComplete()
end

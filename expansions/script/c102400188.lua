--created & coded by Lyris
--フェイツ・ジョーカーガル
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
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_RITUAL_LEVEL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(cid.rlevel)
	c:RegisterEffect(e3)
end
function cid.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0xf7a) and not c:IsCode(id) then
		local clv=c:GetLevel()
		return lv*(0x1<<16)+clv
	else return lv end
end
function cid.filter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf7a) and (ft>0 and c:IsSSetable(true) or c:IsAbleToHand())
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_REMOVED,0,1,nil,Duel.GetLocationCount(tp,LOCATION_SZONE)) end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_REMOVED,0,1,1,nil,ft)
	local tc=g:GetFirst()
	if not tc then return end
	local b1,b2=tc:IsAbleToHand(),tc:IsSSetable(true) and ft>0
	if b1 and (not b2 or Duel.SelectOption(tp,1190,1159)==0) then Duel.SendtoHand(tc,nil,REASON_EFFECT)
	elseif b2 then Duel.SSet(tp,tc)
	else return end
	Duel.ConfirmCards(1-tp,tc)
end

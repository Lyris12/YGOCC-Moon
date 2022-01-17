--created & coded by Lyris, art by 匈歌ハトリ on Pixiv
--襲雷の空
local s,id,off=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetValue(s.hdval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
function s.hdval(e,re,dam,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		return dam/2
	else return dam end
end
function s.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7c4)
end
function s.filter2(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.repfilter(c)
	return (c:IsFaceup() or not c:IsOnField()) and c:IsSetCard(0x7c4) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_REPLACE+REASON_MATERIAL)
end
function s.pfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and c:IsDestructable(e)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil) and Duel.IsExistingMatchingCard(aux.AND(s.filter1,s.pfilter),tp,LOCATION_EXTRA,0,1,nil,e) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.Destroy(Duel.SelectMatchingCard(tp,aux.AND(s.filter1,s.pfilter),tp,LOCATION_EXTRA,0,1,1,nil,e),REASON_EFFECT+REASON_REPLACE)
end

--created by Meedogh, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_BIGBANG))
	e1:SetValue(function(e) return 200+Duel.GetMatchingGroupCount(cid.afilter,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())*200 end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(cid.cost)
	e3:SetTarget(cid.eqtg)
	e3:SetOperation(cid.eqop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(cid.reptg)
	e4:SetValue(cid.repval)
	e4:SetOperation(cid.repop)
	c:RegisterEffect(e4)
end
function cid.afilter(c)
	return c:GetOriginalType()&TYPE_MONSTER~=0 or aux.GetOriginalPandemoniumType(c)~=nil
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_BIGBANG)
end
function cid.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.cfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,cid.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
	local sc=g:GetFirst()
	if sc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tg=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=tg:GetFirst()
		if not Duel.Equip(tp,sc,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(cid.eqlimit)
		sc:RegisterEffect(e1)
	end
end
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function cid.repfilter(c,tp)
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(cid.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	e:SetLabelObject(eg)
	return #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>#eg-1
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cid.repval(e,c)
	return cid.repfilter(c,e:GetHandlerPlayer())
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local qg=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	while tc do
		if not Duel.Equip(tp,tc,qg,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.eqlimit)
		e1:SetLabelObject(qg)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

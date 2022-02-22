-- Terradication Tormentor, Calamitybringer HADES
-- Created and scripted by Swaggy
local cid,id=GetID()
function cid.initial_effect(c)
	--time leap procedure
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,8,cid.sumcon,cid.tlfilter,cid.tlcustomop)
	c:EnableReviveLimit()
	--Toadally Gaiaemperor.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(20181407)
	c:RegisterEffect(e1)
	-- Is This Ivory?
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.actcon)
	e2:SetTarget(cid.acttg)
	e2:SetOperation(cid.actop)
	c:RegisterEffect(e2)
	-- GAUNTLET HA-DUMBASS!
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,id+1000)
	e3:SetCondition(cid.bdogcon)
	e3:SetTarget(cid.damtg)
	e3:SetOperation(cid.damop)
	c:RegisterEffect(e3)
end
function cid.tlcustomop(e,tp,eg,ep,ev,re,r,rp,c,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end

function cid.confilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9b5)
end
function cid.sumcon(e,c)
	return Duel.GetMatchingGroupCount(cid.confilter,c:GetControler(),LOCATION_GRAVE,0,nil)>=5
end
function cid.tlfilter(c,e,mg)
	return c:IsCode(20181407) and c:GetLevel()==e:GetHandler():GetFuture()-1 and c:IsAbleToDeck()
end
function cid.actfilter(c,tp,eg,ep,ev,re,r,rp)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsSetCard(0x9b5)
		and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()) and c:IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp)
end
function cid.excfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
 function cid.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function cid.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.actfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp,eg,ep,ev,re,r,rp)
	end
end
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.actfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		aux.PandAct(tc)(e,tp,eg,ep,ev,re,r,rp)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end
function cid.dmgfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:GetPreviousControler()==1-tp and c:IsPreviousLocation(LOCATION_MZONE)
		and rc and rc:IsType(TYPE_PANDEMONIUM) and rc:IsSetCard(0x9b5) and rc:IsControler(tp) and rc:IsRelateToBattle()
end
function cid.bdogcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.dmgfilter,1,nil,tp) 
end
function cid.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cid.dmgfilter,nil,tp)
	local tc
	if #g==1 then
		tc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		tc=g:Select(tp,1,1,nil)
	end
	local dam=tc:GetPreviousAttackOnField()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,dam,REASON_EFFECT)
end
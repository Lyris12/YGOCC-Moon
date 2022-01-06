-- Terradication Tormentor, Calamitybringer HADES
-- Created and scripted by Swaggy
local cid,id=GetID()
function cid.initial_effect(c)
	--time leap procedure
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,8,cid.sumcon,cid.tlfilter,Duel.SendToDeck,nil,2,REASON_MATERIAL)
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
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,20181417)
	e2:SetCondition(cid.actcon)
	e2:SetTarget(cid.acttg)
	e2:SetOperation(cid.actop)
	c:RegisterEffect(e2)
	-- GAUNTLET HA-DUMBASS!
		local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE)
	e3:SetCountLimit(1,20181417+1000)
	e3:SetCondition(cid.bdogcon)
	e3:SetTarget(cid.damtg)
	e3:SetOperation(cid.damop)
	c:RegisterEffect(e3)
end
function cid.sumcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x9b5)>=5
end
	function cid.tlfilter(c,e,mg)
	return c:IsCode(20184107) and c:GetLevel()==e:GetHandler():GetFuture()-1
end
function cid.actfilter(c,tp)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSetCard(0x9b5) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_GRAVE) (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))))
		and not c:IsForbidden() and not Duel.IsExistingMatchingCard(cid.excfilter,tp,LOCATION_SZONE,0,1,c)
end
function cid.excfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
 function cid.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function cid.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.actfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
end
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.actfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Card.SetCardData(tc,CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		if not tc:IsLocation(LOCATION_SZONE) then
			local edcheck=0
			if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
			Card.SetCardData(tc,CARDDATA_TYPE,TYPE_MONSTER+TYPE_EFFECT+edcheck+aux.GetOriginalPandemoniumType(tc))
		else
			tc:RegisterFlagEffect(726,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE,1)
			tc:RegisterFlagEffect(725,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
		end
	end
end
function cid.dmgfilter(c,tp)
return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup() and c:IsSetCard(0x9b5)
end
function cid.bdogcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return (a:IsType(TYPE_PANDEMONIUM) and a:IsSetCard(0x9b5)) and d:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
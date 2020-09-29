--Wyrm of Fiber Vine 
function c160002123.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
  
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160002123,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetHintTiming(0,0x11e0)
	 e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c160002123.eqcon)
	e1:SetTarget(c160002123.eqtg)
	e1:SetOperation(c160002123.eqop)
	c:RegisterEffect(e1)

	   --destroy & summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(160002123,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,160002123)
	--e2:SetCost(c160002123.spcost)
	e2:SetTarget(c160002123.sptg)
	e2:SetOperation(c160002123.spop)
	c:RegisterEffect(e2)
   --  Duel.AddCustomActivityCounter(160002123,ACTIVITY_SPSUMMON,c160002123.counterfilter)
end
function c160002123.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA
end
function c160002123.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x185a) or c:IsRace(RACE_PLANT) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c160002123.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
function c160002123.cfilter(c)
	return c:IsSetCard(0x185a) and c:IsAbleToRemoveAsCost()
end

function c160002123.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(160002123)==0
end
function c160002123.xfilter(c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)~=0 and c:IsAbleToChangeControler()
end
function c160002123.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)  end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c160002123.xfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c160002123.xfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c160002123.eqlimit(e,c)
	return e:GetOwner()==c
end
function c160002123.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local atk=tc:GetTextAttack()
			local def=tc:GetTextDefense()
			if tc:IsFacedown() or atk<0 then atk=0 end
			if tc:IsFacedown() or def<0 then def=0 end
			if not Duel.Equip(tp,tc,c,false) then return end
			--Add Equip limit
			tc:RegisterFlagEffect(160002123,RESET_EVENT+0x1fe0000,0,0)
			e:SetLabelObject(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			e1:SetValue(c160002123.eqlimit)
			tc:RegisterEffect(e1)
			if atk>0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+0x1fe0000)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
			if def>0 then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_EQUIP)
				e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				e3:SetReset(RESET_EVENT+0x1fe0000)
				e3:SetValue(def)
				tc:RegisterEffect(e3)
			end
			--substitute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(c160002123.repval)
	tc:RegisterEffect(e2)
	end
end
end
function c160002123.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0
end
function c160002123.spfilter(c,e,tp)
	return c:IsSetCard(0x185a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c160002123.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(160002123,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c160002123.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c160002123.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x85a)
end

function c160002123.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() 
		and Duel.IsExistingMatchingCard(c160002123.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c160002123.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c160002123.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
			   local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c160002123.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	   Duel.SpecialSummonComplete()  
	end
end
end
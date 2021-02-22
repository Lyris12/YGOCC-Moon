--Coded-Eyes Machina Lion
function c1020029.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--immune
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_PZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xded))
	e0:SetValue(c1020029.efilter)
	c:RegisterEffect(e0)
	--all limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c1020029.nOlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	local e5b=e3:Clone()
	e5b:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e5b)
	--special summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(1020029,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCondition(c1020029.condition)
	e6:SetTarget(c1020029.target)
	e6:SetOperation(c1020029.operation)
	c:RegisterEffect(e6)
	--lvchange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020029,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1020029.lvtg)
	e1:SetOperation(c1020029.lvop)
	c:RegisterEffect(e1)
end
function c1020029.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end
function c1020029.nOlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xded)
end
function c1020029.ssdfilter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()==tp and c:IsSetCard(0xded)
end
function c1020029.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(c1020029.ssdfilter,1,nil,tp) and Duel.GetFlagEffect(tp,1020029)==0
end
function c1020029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c1020029.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetFlagEffect(tp,1020029)==0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			Duel.RegisterFlagEffect(tp,1020029,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function c1020029.filter(c)
	return c:IsFaceup() and not c:IsStatus(STATUS_NO_LEVEL) and c:IsSetCard(0xded)
end
function c1020029.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1020029.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1020029.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c1020029.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function c1020029.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

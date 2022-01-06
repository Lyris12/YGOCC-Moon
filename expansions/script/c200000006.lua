--Naval Gears - Leipzig
local cid,id=GetID()
function cid.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,cid.lfilter,2,2)
    c:EnableReviveLimit()
		--on sp summon: set machine to back row
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65330383,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.setcon)
	e1:SetTarget(cid.settg)
	e1:SetOperation(cid.setop)
	c:RegisterEffect(e1)
	--if sp summon while in back row: sp summon 2 from back row
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16898077,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(cid.sptg)
	e5:SetOperation(cid.spop)
	c:RegisterEffect(e5)
end
function cid.lfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x700)
end
--if sp summon while in back row: sp summon 2 from back row
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function cid.spfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	 if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and 
	 c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1) then
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
	 Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(c)
		e2:SetCondition(cid.descon)
		e2:SetOperation(cid.desop)
		Duel.RegisterEffect(e2,c)
	end
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
--on sp summon: set machine to back row
function cid.setfilter(c)
	return not c:IsForbidden() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and not c:IsCode(id)
end
function cid.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return cid.setfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_DECK) and chkc:IsLocation(LOCATION_EXTRA) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(cid.setfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
	 Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
	   local e1=Effect.CreateEffect(e:GetHandler())
	   e1:SetCode(EFFECT_CHANGE_TYPE)
	   e1:SetType(EFFECT_TYPE_SINGLE)
	   e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	   e1:SetReset(RESET_EVENT+0x1fc0000)
	   e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	   tc:RegisterEffect(e1)
	end


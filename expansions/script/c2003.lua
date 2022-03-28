--X-Ergoriesumato Jetfusocodice
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.econ)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetLabelObject(e2)
	e2x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2x)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2x)
	c:RegisterEffect(e3)
	--material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.ctcon)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
function s.ffilter(c)
	return c:GetOriginalCode()<10000000
end

function s.econ(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
function s.efilter(e,re,rp)
	local rc=re:GetHandler()
	return rc and rc:GetOriginalCode()>e:GetLabel()
end
function s.countop(e)
	if e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) then
		e:GetHandler():SetHint(CHINT_NUMBER,e:GetLabel())
	end
	e:Reset()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g then
		e:GetLabelObject():SetLabel(0)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
	else
		local ct=g:GetSum(Card.GetOriginalCode)
		e:GetLabelObject():SetLabel(ct)
		e:GetLabelObject():GetLabelObject():SetLabel(ct)
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,2))
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_SPSUMMON_SUCCESS)
		e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetLabel(ct)
		e0:SetOperation(s.countop)
		c:RegisterEffect(e0)
	end
end

function s.thfilter(c)
	return c:IsType(TYPE_ST) and c:IsSetCard(ARCHE_FUSION) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return (not re or re:GetHandler()~=e:GetHandler())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(s.subcon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
	e:GetHandler():RegisterEffect(e2)
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_ONFIELD)
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r==REASON_FUSION and rc:IsType(TYPE_FUSION) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.ToExtraSelfCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.spf(c,e,tp,codes)
	local check=false
	for _,code in ipairs(codes) do
		if c:GetOriginalCode()<code then
			check=true
		end
	end
	return check and c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0 or not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,e:GetHandler())>0)
end
function s.nf(c,codes)
	local check=false
	for _,code in ipairs(codes) do
		if c:GetOriginalCode()>code then
			check=true
		end
	end
	return check and aux.NegateAnyFilter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local codes=(c:IsOnField()) and {c:GetCode()} or {c:GetPreviousCodeOnField()}
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,codes) and Duel.IsExistingMatchingCard(s.nf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,codes)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local codes={c:GetPreviousCodeOnField()}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spf),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,codes)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		local tc=Duel.SelectMatchingCard(tp,s.nf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,codes):GetFirst()
		if tc then
			Duel.HintSelection(Group.FromCards(tc))
			Duel.Negate(tc,e)
		end
	end
end		
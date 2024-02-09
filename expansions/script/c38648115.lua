--Arvolene, Divinità di Elyria
--Script by XGlitchy30
function c38648115.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,0x841),3)
	c:EnableReviveLimit()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c38648115.tgcon)
	e1:SetValue(c38648115.efilter)
	c:RegisterEffect(e1)
	local mcheck=Effect.CreateEffect(c)
	mcheck:SetType(EFFECT_TYPE_SINGLE)
	mcheck:SetCode(EFFECT_MATERIAL_CHECK)
	mcheck:SetValue(c38648115.valcheck)
	mcheck:SetLabelObject(e1)
	c:RegisterEffect(mcheck)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38648115,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c38648115.sptg)
	e2:SetOperation(c38648115.spop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38648115,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,38648115)
	e3:SetCost(c38648115.drycost)
	e3:SetTarget(c38648115.drytg)
	e3:SetOperation(c38648115.dryop)
	c:RegisterEffect(e3)
end
--filters
function c38648115.spfilter(c,e,tp,zone)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c38648115.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function c38648115.checkfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_EFFECT)
end
--protection
function c38648115.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c38648115.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
function c38648115.efilter(e,te)
	return e:GetHandlerPlayer()~=te:GetOwnerPlayer() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
--special summon
function c38648115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone()
		return zone~=0 and Duel.IsExistingMatchingCard(c38648115.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c38648115.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local ct=2
	if zone~=0 and c:IsRelateToEffect(e) then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		if zone<2 then ct=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648115.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ct,nil,e,tp,zone)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end
--destroy
function c38648115.drycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38648115.cfilter,1,nil) end
	local cg=Duel.SelectReleaseGroup(tp,c38648115.cfilter,1,1,nil)
	Duel.Release(cg,REASON_COST)
end
function c38648115.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c38648115.checkfilter(chkc,e,1-tp) end
	if chk==0 then return eg:IsExists(c38648115.checkfilter,1,nil,e,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function c38648115.dryop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(eg,REASON_EFFECT)
end
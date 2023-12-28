--Ploutonion, Portale Nottesfumo della Decadenza
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e1:SetValue(500)
	c:RegisterEffect(e1)	
	--bulleted effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--spsummon synchro
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:HOPT()
	e4:SetCost(s.syncost)
	e4:SetTarget(s.syntg)
	e4:SetOperation(s.synop)
	c:RegisterEffect(e4)
	--replace field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE|PHASE_END)
	e5:SetRange(LOCATION_FZONE)
	e5:HOPT()
	e5:SetCost(s.actcost)
	e5:SetTarget(s.acttg)
	e5:SetOperation(s.actop)
	c:RegisterEffect(e5)
end
--filters
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_NIGHTSHADE)
end
function s.spfilter(c,f)
	if not c:IsSetCard(ARCHE_NIGHTSHADE) then return false end
	if not f then
		return c:IsAbleToRemove() or c:IsAbleToGrave()
	else
		return f(c)
	end
end
function s.fieldfilter(c,tp)
	return c:IsCode(62613315) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
--special summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil) end
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,Card.IsAbleToRemove)
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,Card.IsAbleToGrave)
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	local cat = opt==0 and CATEGORY_REMOVE or CATEGORY_TOGRAVE
	e:SetCategory(cat)
	Duel.SetOperationInfo(0,cat,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	local f = opt==0 and Card.IsAbleToRemove or Card.IsAbleToGrave
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,f)
	if #sg>0 then
		if opt==0 then
			Duel.Banish(sg)
		else
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end

--special summon synchro
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NIGHTSHADE) and c:GetOverlayGroup():IsExists(Card.IsMonster,1,nil,TYPE_SYNCHRO)
		and Duel.GetMZoneCount(tp,c)>0
end
function s.synfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(ARCHE_NIGHTSHADE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(REASON_COST,tp,s.cfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(REASON_COST,tp,s.cfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.synfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then 
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--replace field
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
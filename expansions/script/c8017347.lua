--Spaziovocazione di Zextra
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	c:RegisterEffect(e1)
	--maintain cost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.pcond)
	e2:SetTarget(cid.ptarget)
	e2:SetOperation(cid.poperation)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.spcon)
	e3:SetCost(cid.spcost)
	e3:SetTarget(cid.sptg)
	e3:SetOperation(cid.spop)
	c:RegisterEffect(e3)
end
--ACTIVATE
function cid.dfilter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function cid.spfilter(c,e,tp,m)
	if bit.band(c:GetType(),TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM)~=TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM
	or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) or (c:IsLocation(LOCATION_HAND) and c:IsPublic()) then 
		return false 
	end
	local dg=Duel.GetMatchingGroup(cid.dfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if c.mat_filter then
		dg=dg:Filter(c.mat_filter,c,tp)
	else
		dg:RemoveCard(c)
	end
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,c:GetLevel()*2,"Equal")
	local res=mg:CheckSubGroup(cid.fselect,1,c:GetLevel()*2,c)
	aux.GCheckAdditional=nil
	return res
end
function cid.fselect(g,mc)
	return aux.RitualCheck(g,tp,mc,mc:GetLevel()*2,"Equal")
end
-----------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(cid.activate)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		local dg=Duel.GetMatchingGroup(cid.dfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if tc.mat_filter then
			dg=dg:Filter(tc.mat_filter,tc,tp)
		else
			dg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel()*2,"Equal")
		local mat=dg:SelectSubGroup(tp,cid.fselect,false,1,tc:GetLevel()*2,tc)
		aux.GCheckAdditional=nil
		if not mat or mat:GetCount()==0 then return end
		tc:SetMaterial(mat)
		if Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		Duel.BreakEffect()
		if not tc:IsLocation(LOCATION_HAND+LOCATION_DECK) then return end
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		if (tc:IsSetCard(0xf78) or tc:IsSetCard(0xf79)) and c:IsCanTurnSet() then
			Duel.ChangePosition(c,POS_FACEDOWN)
			Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		end
	end
end
--MAINTAIN COST
--filters
function cid.filter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsFacedown()) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
---------------
function cid.pcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(cid.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function cid.ptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function cid.poperation(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local g=Duel.GetMatchingGroup(cid.filter,p,LOCATION_MZONE,0,nil)
		if #g>0 then
			if Duel.CheckLPCost(p,1000) and Duel.SelectYesNo(p,aux.Stringid(id,2)) then
				Duel.PayLPCost(p,1000)
			else
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
--SPSUMMON
function cid.cfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCode(id)
end
function cid.spfilter(c,e,tp)
	return bit.band(c:GetType(),TYPE_MONSTER+TYPE_PANDEMONIUM+TYPE_RITUAL)==TYPE_MONSTER+TYPE_PANDEMONIUM+TYPE_RITUAL and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function cid.efilter(e,re)
	return e:GetOwnerPlayer()==re:GetOwnerPlayer() and e:GetHandler()~=re:GetHandler()
end
function cid.econd(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
----------
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		return #g>0 and g:FilterCount(Card.IsAbleToRemoveAsCost,nil)==#g
	end
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local g2=g:Filter(Card.IsAbleToRemoveAsCost,nil)
	if #g2>=#g then
		Duel.Remove(g2,POS_FACEUP,REASON_COST)
	end
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_DISABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(cid.efilter)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_BASE_ATTACK)
		e3:SetValue(4000)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabelObject(tc)
		e4:SetCondition(cid.drycon)
		e4:SetOperation(cid.dryop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		Duel.RegisterEffect(e4,tp)
	end
	Duel.SpecialSummonComplete()
end
function cid.drycon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function cid.dryop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
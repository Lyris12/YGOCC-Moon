--Daylilly Field
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnableChangeCode(c,CARD_BLACK_GARDEN,LOCATION_SZONE)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--place
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetCost(aux.DummyCost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.cfilter1(c,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and (c:IsFaceup() or c:IsControler(tp))
end
function s.fgoal(g,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.spfilter(c,e,tp,g)
	if not (c:IsFaceup() and c:IsMonster(TYPE_FUSION) and c:IsRace(RACE_ALL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.lairfilter_forced(c,tp,g)
	return c:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp) and not g:IsContains(c)
end
function s.lairfilter_optional(c,tp,g)
	return c:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp) and g:IsContains(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.cfilter1,nil,tp)
	if chk==0 then return #g1>1 and g1:CheckSubGroup(s.fgoal,2,2,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local rg=g1:SelectSubGroup(tp,s.fgoal,false,2,2,e,tp)
	
	local exg=rg:Filter(Auxiliary.ExtraReleaseFilter,nil,tp)
	local exg1=exg:Filter(s.lairfilter_forced,nil,tp,g2)
	local exg2=exg:Filter(s.lairfilter_optional,nil,tp,g2)
	local te
	if #exg1>0 then
		local tc=exg1:Select(tp,1,1,nil):GetFirst()
		te=tc:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
	elseif #exg2>0 and Duel.SelectYesNo(tp,STRING_ASK_EXTRA_RELEASE_NONSUM) then
		local tc=exg2:Select(tp,1,1,nil):GetFirst()
		te=tc:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
	end
	if te then
		Duel.Hint(HINT_CARD,tp,te:GetHandler():GetOriginalCode())
		te:UseCountLimit(tp)
	end
	
	Duel.Release(rg,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.filter(c,tp)
	return c:IsMonster(TYPE_PENDULUM) and c:IsRace(RACE_PLANT) and c:CheckUniqueOnField(tp,LOCATION_PZONE) and not c:IsForbidden()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp) and #g>0
			and (Duel.CheckPendulumZones(tp) or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,0x1f00)>-1)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if #sg>0 then
		local tc=sg:GetFirst()
		if tc:IsFaceup() then
			Duel.HintMessage(1-tp,aux.Stringid(id,3))
			sg:Select(1-tp,0,1,nil)
		else
			Duel.ConfirmCards(1-tp,tc)
		end
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_PZONE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.CheckPendulumZones(tp) then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToChain() then
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end

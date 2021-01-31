--Extra-Mastery Xyz Phantom
function c249001143.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44161893,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,249001143)
	e1:SetCondition(c249001143.spcon)
	e1:SetTarget(c249001143.sptg)
	e1:SetOperation(c249001143.spop)
	c:RegisterEffect(e1)
	--spsummon proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249001143.spcon2)
	c:RegisterEffect(e2)
end
function c249001143.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and bit.band(c:GetPreviousTypeOnField(),TYPE_FUSION+TYPE_SYNCHRO)~=0 
		and c:IsReason(REASON_EFFECT)
end
function c249001143.confilter(c)
	return c:IsSetCard(0x22C) and c:GetCode()~=249001143
end
function c249001143.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249001143.cfilter,1,nil,tp,rp) and Duel.IsExistingMatchingCard(c249001143.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c249001143.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001143.fselect(g,tp,c)
	return g:IsContains(c)
		and Duel.IsExistingMatchingCard(c249001143.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
function c249001143.xyzfilter(c,g)
	return c:IsXyzSummonable(g,2,2)
end
function c249001143.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c249001143.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(c249001143.fselect,2,2,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function c249001143.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c249001143.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,c249001143.fselect,false,2,2,tp,e:GetHandler())
	if sg and sg:GetCount()==2 then
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4)
		Duel.SpecialSummonComplete()
		local xyzg=Duel.GetMatchingGroup(c249001143.xyzfilter,tp,LOCATION_EXTRA,0,nil,sg)
		if xyzg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			Duel.XyzSummon(tp,xyz,sg)
		end
	end
end
function c249001143.spcon2(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
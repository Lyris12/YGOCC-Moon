--Hisaki, Maestro dei Sigilli Evocato
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--atk
	c:UpdateATK(s.atkval)
	--protection
	c:TargetProtectionField(PROTECTION_FROM_OPPONENT,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0x7eb))
	--ss
	c:SentToGYFieldTrigger(s.cfilter,false,0,CATEGORY_SPECIAL_SUMMON,true,LOCATION_HAND,true,
		nil,
		nil,
		s.sptg,
		s.spop
	)
end
function s.atkval(e,c)
	local en=Duel.GetEngagedCard(e:GetHandlerPlayer())
	if not en or not en:IsMonster() or not en:IsSetCard(0x7eb) then return 0 end
	local ct,og=en:GetEnergy(),en:GetOriginalEnergy()
	if ct>=og then return 0 end
	return (og-ct)*100
end

function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x7eb) and c:DueToHavingZeroEnergy()
end
function s.dspfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x7eb) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_HAND,0,1,c,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.BreakEffect()
			Duel.SpecialSummonRedirect(e,sc,0,tp,tp,true,false,POS_FACEUP,nil,nil,aux.Stringid(id,1))
		end
	end
end
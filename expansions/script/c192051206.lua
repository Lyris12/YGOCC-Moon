--coded by Lyris
local s,id=GetID()
function s.initial_effect(c)   
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e)
		return e:GetHandler():GetSummonLocation()==LOCATION_GRAVE
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	local lv=c:GetLevel()+e:GetHandler():GetLevel()
	return c:IsSetCard(0x617) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_TUNER)
		and (Group.FromCards(c,e:GetHandler()):CheckWithSumEqual(Card.GetLevel,6,2,2)
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,6))
		or (Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(function(c)
			return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsCanBeSynchroMaterial() and not c:IsType(TYPE_TUNER)
		end,e:GetHandler()):CheckWithSumEqual(Card.GetLevel,9-lv,1,99)
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,9))
end
function s.exfilter(c,e,tp,code)
	return c:GetLevel()==code and c:IsSetCard(0x617) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.exfilter2(c,e,tp)
	return c:IsCode(id+9,id+10) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local other=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(function(c) return c:IsFaceup() and c:IsSetCard(0x617) end,e:GetHandler())
	if chk==0 then
		if other>0 then
			if true then return Duel.GetLocationCountFromEx(tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and
				Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and
				(Duel.IsPlayerCanSpecialSummonMonster(tp,id+9,0x617,0x2021,2600,1550,6,0x2000,0x10,0x5,tp,SUMMON_TYPE_SYNCHRO) and
				Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,6)) or
				Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,0x617,0x2021,3200,2300,9,0x2000,0x10,0x5,tp,SUMMON_TYPE_SYNCHRO)
			end
		else
			return Duel.GetLocationCountFromEx(tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and
				Duel.IsPlayerCanSpecialSummonMonster(tp,id+9,0x617,0x2021,2600,1550,6,0x2000,0x10,0x5,tp,SUMMON_TYPE_SYNCHRO) and
				Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local other=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(function(c) return c:IsFaceup() and c:IsRace(RACE_DRAGON) end,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetHandler():IsRelateToEffect(e) then
		sg:AddCard(e:GetHandler())
		Duel.BreakEffect()
		local mg=Duel.GetMatchingGroup(function(c,lc,g)
			return c:IsFaceup() and c:IsCanBeSynchroMaterial() and c:IsRace(RACE_DRAGON) and not g:IsContains(c)
		end,tp,LOCATION_MZONE,0,nil,c,sg)
		lv=0
		tc=sg:GetFirst()
		for i=1,#sg do lv=lv+tc:GetLevel() tc=sg:GetNext() end
		if other>0 and mg:CheckWithSumEqual(Card.GetLevel,9-lv,1,1) then
			fc=Duel.SelectMatchingCard(tp,s.exfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		else
			fc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,6):GetFirst()
		end
		if not fc then return end
		local code=fc:GetCode()
		if code==id+9 then
			g=sg
		elseif code==id+10 then
			g=sg
			tg=mg:SelectWithSumEqual(tp,Card.GetLevel,9-lv,1,1)
			g:Merge(tg)
		end
		fc:SetMaterial(g)
		Duel.SendtoGrave(g,REASON_SYNCHRO+REASON_MATERIAL+REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SpecialSummon(fc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	end
end

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
	return c:IsSetCard(0x617) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.exfilter2(c,e,tp)
	return c:IsCode(id+10,id+11) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local other=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(Card.IsSetCard,e:GetHandler(),0x617)
	if chk==0 then
		if other>0 then
			if true then return Duel.GetLocationCountFromEx(tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
				Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and
				((Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,0x617,0x21+TYPE_XYZ,1800,1300,3,0x2000,0x10,0x5,tp,SUMMON_TYPE_XYZ) and
				Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,id+10)) or
				Duel.IsPlayerCanSpecialSummonMonster(tp,id+11,0x617,0x21+TYPE_XYZ,2600,1900,3,0x2000,0x10,0x5,tp,SUMMON_TYPE_XYZ) and
				Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,id+11))
			end
		else
			return Duel.GetLocationCountFromEx(tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
				Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,0x617,0x21+TYPE_XYZ,1800,1300,3,0x2000,0x10,0x5,tp,SUMMON_TYPE_XYZ) and
				Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,id+10) and
				Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	local other=Duel.GetMatchingGroupCount(s.f,tp,LOCATION_MZONE,0,nil,Group.FromCards(c,sc))
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		if other>0 then
			fc=Duel.SelectMatchingCard(tp,s.exfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		else
			fc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,id+10):GetFirst()
		end
		if not fc then return end
		local code=fc:GetCode()
		if code==id+10 then
			g=Group.FromCards(c,sc)
		elseif code==id+11 then
			g=Group.FromCards(c,sc)
			local tg=Duel.GetMatchingGroup(s.f,tp,LOCATION_MZONE,0,nil,g):Select(tp,1,1,nil)
			if tg then g:AddCard(tg:GetFirst()) end
		end
		Duel.XyzSummon(tp,fc,g)
	end
end
function s.f(c,g) return c:IsFaceup() and c:IsSetCard(0x617) and not g:IsContains(c) and c:GetLevel()==3 end
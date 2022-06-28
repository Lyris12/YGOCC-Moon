--Levelution Axelotl
local ref=_G['c'..30039203]
function c30039203.initial_effect(c)

	--special summon self
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30039213)
	e1:SetCondition(c30039203.spcon)
	e1:SetTarget(c30039203.sptg)
	e1:SetOperation(c30039203.spop)
	c:RegisterEffect(e1)
		if not c30039203.global_check then
		c30039203.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c30039203.checkop)
		Duel.RegisterEffect(ge1,0)
	end

	--Combine Levelutions
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30039203)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
end
	
function c30039203.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (bit.band(r,REASON_BATTLE)>0 or bit.band(r,REASON_EFFECT)~=0) then
		Duel.RegisterFlagEffect(ep,30039203,RESET_PHASE+PHASE_END,0,1)
end
end
	
function c30039203.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,30039203)~=0
end

function c30039203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c30039203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
	
function ref.ssfilter(c,e,tp,lv)
	return c:IsSetCard(0x93f) and c:GetLevel()==lv
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function ref.matfilter(c,tp)
	return c:IsSetCard(0x93f)
end
function ref.ssfilterchk(c,e,tp,mg)
	return c:IsSetCard(0x93f) and mg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,64,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0x93f)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.ssfilterchk,tp,LOCATION_DECK,0,1,nil,e,tp,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,ref.ssfilterchk,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg):GetFirst()
	local sg=mg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),2,64)
	local lv=0
	local lvc=sg:GetFirst()
	while lvc do
		lv=lv+lvc:GetLevel()
		lvc=sg:GetNext()
	end
	e:SetLabel(lv)
	Duel.Release(sg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

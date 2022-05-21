--Gelatyna Gigante
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--attack down
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAttackAbove(100)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackAbove(100) and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,PLAYER_ALL,LOCATION_MZONE,-100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g<=0 then return end
	local tg,atk=g:GetMaxGroup(Card.GetAttack)
	local catk=c:GetAttack()
	local maxc=math.min(catk,atk)
	local ct=math.floor(maxc/100)
	local t={}
	for i=1,ct do
		t[i]=i*100
	end
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	local e1=c:UpdateATK(-cost,true)
	local diff=catk-c:GetAttack()
	if diff>0 then
		local tc=Duel.Select(HINTMSG_FACEUP,false,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if tc and tc:IsFaceup() then
			Duel.HintSelection(Group.FromCards(tc))
			tc:UpdateATK(-diff,true,c)
		end
	end
end

function s.spfilter(c,e,tp)
	return c:IsMonster() and c:HasLevel() and c:IsSetCard(0x296) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,g)
	return g:IsExists(Card.IsLevel,1,c,c:GetLevel())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetLabel()==1 and e:GetHandler():IsLocation(LOCATION_MZONE) and e:GetHandler():GetSequence()<5 then ft=ft+1 end
		e:SetLabel(0)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		return #g>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ft>1 and g:IsExists(s.filter2,1,nil,g)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	local dg=g:Filter(s.filter2,nil,g)
	if #dg>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=dg:Select(tp,1,1,nil)
		local tc1=sg:GetFirst()
		if not tc1 then return end
		dg:RemoveCard(tc1)
		local tc2=dg:FilterSelect(tp,Card.IsLevel,1,1,tc1,tc1:GetLevel()):GetFirst()
		if not tc2 then return end
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
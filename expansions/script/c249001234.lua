--Emerald Summoner Knight
function c249001234.initial_effect(c)
	c:EnableCounterPermit(0x8)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c249001234.countercon)
	e1:SetTarget(c249001234.countertg)
	e1:SetOperation(c249001234.counterop)
	c:RegisterEffect(e1)
	--spsummon remove counters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c249001234.sptg)
	e2:SetOperation(c249001234.spop)
	c:RegisterEffect(e2)
	--special summon self
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c249001234.spcon)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(2)
	e4:SetValue(c249001234.valcon)
	c:RegisterEffect(e4)
end
function c249001234.countercon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetBattleTarget() == nil then return false end
	return 	e:GetHandler():GetBattleTarget():GetLevel()>0 or e:GetHandler():GetBattleTarget():GetRank()>0 or e:GetHandler():GetBattleTarget():GetLink()>0
end
function c249001234.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct = e:GetHandler():GetBattleTarget():GetLevel()
	if ct == 0 then ct = e:GetHandler():GetBattleTarget():GetRank() * 2 end
	if ct == 0 then ct = e:GetHandler():GetBattleTarget():GetLink() * 2 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x8)
end
function c249001234.counterop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsRelateToBattle() and e:GetHandler():GetBattleTarget():IsRelateToBattle() then
		local ct = e:GetHandler():GetBattleTarget():GetLevel()
		if ct == 0 then ct = e:GetHandler():GetBattleTarget():GetRank() * 2 end
		if ct == 0 then ct = e:GetHandler():GetBattleTarget():GetLink() * 2 end
		if ct > 0 then e:GetHandler():AddCounter(0x8,ct) end
	end
end
function c249001234.spfilter(c,cc,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()>0 and cc:IsCanRemoveCounter(tp,0x8,c:GetLevel(),REASON_COST)
end
function c249001234.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249001234.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e:GetHandler(),e,tp) end
	local g=Duel.GetMatchingGroup(c249001234.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e:GetHandler(),e,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6061630,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x8,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
function c249001234.spfilter2(c,lv,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(lv)
end
function c249001234.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001234.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,lv,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function c249001234.spfilter3(c)
	return c:IsFaceup() and c:IsSetCard(0x234) and not c:IsCode(249001234)
end
function c249001234.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c249001234.spfilter3,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c249001234.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
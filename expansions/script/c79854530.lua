--If your opponent controls a monster and you control no monsters: You can Special Summon this card
-- (from your hand). If you do: You can send 1 Level 3 or lower Plant Tuner from your Deck to the 
--GY. If a face-up Synchro Monster you control is destroyed by your opponents card (either by battle
-- or by a card effect) while this card is in your GY: You can Special Summon this card and if you 
--do, add 1 Level 3 or lower Plant Monster from your GY to your hand. You can only Special Summon 
--"Natural Synchron" once per turn.

function c79854530.initial_effect(c)
	c:SetSPSummonOnce(79854530)
	--special summon fromhand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79854530.spcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--millplants
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79854530,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c79854530.condition)
	e2:SetTarget(c79854530.target)
	e2:SetOperation(c79854530.operation)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79854530,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c79854530.spcon1)
	e3:SetTarget(c79854530.sptg1)
	e3:SetOperation(c79854530.spop1)
	c:RegisterEffect(e3)
end
--specialsummon
function c79854530.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
--millplants
function c79854530.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c79854530.filter(c)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_TUNER) and c:IsLevelBelow(3) and c:IsAbleToGrave()
end
function c79854530.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c79854530.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c79854530.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c79854530.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c79854530.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_SYNCHRO)~=0
end
function c79854530.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79854530.spcfilter,1,nil,tp)
end
function c79854530.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMatchingGroupCount(function(c) return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT) and c:IsAbleToHand() end,tp,LOCATION_GRAVE,0,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c79854530.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
		return
	end
	local g=Duel.GetMatchingGroup(function(c) return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT) and c:IsAbleToHand() end,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
--Xoloscorch the Infernal Inferno
--Xoloscorch l'Inferno Infernale
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--[[You can Normal Summon/Set this card without Tributing, but its original ATK becomes 1800.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetOperation(s.ntop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e1x)
	--[[When this card is Normal Summoned: You can draw 2 cards, then place 2 cards from your hand on the bottom of your Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(nil,nil,s.drawtg,s.drawop)
	c:RegisterEffect(e2)
	--[[Once per turn, during the Main Phase (Quick Effect): You can discard 1 card; destroy all face-up monsters your opponent controls with ATK less than or equal to this card's.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetRelevantTimings()
	e3:SetFunctions(aux.MainPhaseCond(),aux.DiscardCost(),s.target,s.operation)
	c:RegisterEffect(e3)
	--[[Once per turn, during the Standby Phase, if this card is in your GY because it was sent there from the field after being Normal Summoned/Set: You can Special Summon this card.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(3)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:OPT()
	e4:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e4)
end
--E1
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1700)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD|RESET_DISABLE)
	c:RegisterEffect(e1)
end

--E2
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,2,2,nil)
		if #g>0 then
			Duel.BreakEffect()
			aux.PlaceCardsOnDeckBottom(p,g)
		end
	end
end

--FE3
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
--E3
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:HasAttack() then return false end
		local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
		return #g>0
	end
	local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:HasAttack() then
		local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
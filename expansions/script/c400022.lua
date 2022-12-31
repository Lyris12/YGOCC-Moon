--Gli Ordini dell'Angelo
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--archetype and type
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e0:SetValue(0x246)
	c:RegisterEffect(e0)
	local e0x=e0:Clone()
	e0x:SetCode(EFFECT_CHANGE_TYPE)
	e0x:SetValue(TYPE_SPELL+TYPE_QUICKPLAY)
	c:RegisterEffect(e0x)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--tokens
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.tkcon)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c,tp,typ)
	if not c:IsSetCard(0x246) or not c:IsType(typ) or not c:IsAbleToHand() then return false end
	if typ==TYPE_MONSTER then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,tp,TYPE_SPELL)
	end
	return true
end
function s.sumfilter(c)
	return c:IsMonster() and c:IsSetCard(0x246) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp,TYPE_MONSTER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,tp,TYPE_MONSTER)
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		if #sg1>0 then
			local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,sg1:GetFirst(),tp,TYPE_SPELL)
			if #g2>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg2=g2:Select(tp,1,1,nil)
				sg1:Merge(sg2)
			end
			if #sg1==2 then
				local ct,hg=Duel.Search(sg1,tp)
				if hg==2 and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.ShuffleHand(tp)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
					if sc then
						Duel.Summon(tp,sc,true,nil)
					end
				end
			end
		end
	end
end

function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(400001,400002)
end
function s.tkcon(e,tp)
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.costfilter(c)
	return c:IsMonster(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsSetCard(0x246) and c:IsAbleToRemoveAsCost()
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,400009,0x246,TYPES_TOKEN_MONSTER,1700,1000,4,RACE_FAIRY,ATTRIBUTE_WATER)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,400023,0x246,TYPES_TOKEN_MONSTER,1000,1700,4,RACE_FAIRY,ATTRIBUTE_WATER)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,400024,0x246,TYPES_TOKEN_MONSTER,1350,1350,4,RACE_FAIRY,ATTRIBUTE_WATER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<3 
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,400009,0x246,TYPES_TOKEN_MONSTER,1700,1000,4,RACE_FAIRY,ATTRIBUTE_WATER)
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,400023,0x246,TYPES_TOKEN_MONSTER,1000,1700,4,RACE_FAIRY,ATTRIBUTE_WATER)
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,400024,0x246,TYPES_TOKEN_MONSTER,1350,1350,4,RACE_FAIRY,ATTRIBUTE_WATER) then
		return
	end
	local token1, token2, token3 = Duel.CreateToken(tp,400009), Duel.CreateToken(tp,400023), Duel.CreateToken(tp,400024)
	Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(token3,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
	
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
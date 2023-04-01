--Esprision Support Spirits
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Activate()
	--The first time each Xyz Monster without materials you control would be destroyed by battle or card effect, it is not destroyed.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)
	--[[During your turn, if you Xyz Summon an "Esprision" Xyz Monster(s): You can add 1 Level 3 Beast monster from your Deck to your hand,
	then toss a coin and if the result is heads, discard 1 card, or if the result is tails, destroy this card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_COIN|CATEGORY_HANDES|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetCondition(s.sccon)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end
s.toss_coin=true

function s.indtg(e,c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function s.indct(e,re,r,rp)
	if r&(REASON_BATTLE|REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end

function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsMonster(TYPE_XYZ) and c:IsSetCard(0xe50) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.filter(c)
	return c:IsMonster() and c:IsLevel(3) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local heads=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		local tails=c:IsDestructable()
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and (heads or tails)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local ct,hct=Duel.Search(g,tp)
		if hct>0 then
			Duel.BreakEffect()
			local c=e:GetHandler()
			local coin=Duel.TossCoin(tp,1)
			if coin==COIN_HEADS then
				Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
				
			elseif coin==COIN_TAILS and c:IsRelateToChain() then
				Duel.Destroy(c,REASON_EFFECT)
			end
		end
	end
end
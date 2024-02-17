--Conjuration-Spellbook of Battle
function c249001289.initial_effect(c)
	aux.AddCodeList(c,249001289,44095762,68833958,70342110,83746708,55713623)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1249001289+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c249001289.condition)
	e1:SetTarget(c249001289.target)
	e1:SetOperation(c249001289.activate)
	c:RegisterEffect(e1)
end
function c249001289.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_SPELLCASTER)
end
function c249001289.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001289.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c249001289.drfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
function c249001289.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetMatchingGroupCount(c249001289.drfilter,tp,LOCATION_GRAVE,0,nil)>=3 then
		e:SetCategory(CATEGORY_DRAW)
	else
		e:SetCategory(0)
	end
end
function c249001289.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local token=Duel.CreateToken(tp,44095762)
	g:AddCard(token)
	token=Duel.CreateToken(tp,68833958)
	g:AddCard(token)
	token=Duel.CreateToken(tp,70342110)
	g:AddCard(token)
	token=Duel.CreateToken(tp,83746708)
	g:AddCard(token)
	token=Duel.CreateToken(tp,55713623)
	g:AddCard(token)
	local sg=g:RandomSelect(tp,2,2)
	Duel.ConfirmCards(1-tp,sg)
	local tg=sg:Select(tp,1,1,nil)
	Duel.SendtoHand(tg,nil,REASON_RULE)
	if Duel.IsPlayerCanDraw(tp,1)
		and Duel.GetMatchingGroupCount(c249001289.drfilter,tp,LOCATION_GRAVE,0,nil)>=3
		and Duel.SelectYesNo(tp,aux.Stringid(63166095,0)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	e:SetCategory(0)
end

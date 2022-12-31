--AoJ - Il Chierico
--Script by XGlitchy30
function c19772605.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x197),2,2)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772605,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1)
	e1:SetCondition(c19772605.dwcon)
	e1:SetTarget(c19772605.dwtg)
	e1:SetOperation(c19772605.dwop)
	c:RegisterEffect(e1)
end
--filters
function c19772605.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
--draw
function c19772605.dwcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_LINK and c:GetReasonCard():IsSetCard(0x197)
end
function c19772605.dwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c19772605.dwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0x197) then
			local g=Duel.GetMatchingGroup(c19772605.setfilter,tp,0,LOCATION_MZONE,nil)
			if g:GetCount()>0 then
				Duel.BreakEffect()
				local sg=g:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
			end
		end
		Duel.ShuffleHand(tp)
	end
end
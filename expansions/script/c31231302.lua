--Balder, Cascad Captain
--Script by XGlitchy30
function c31231302.initial_effect(c)
	--rearrange and spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31231302,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31231302)
	e1:SetCondition(c31231302.spcon)
	e1:SetCost(c31231302.spcost)
	e1:SetTarget(c31231302.sptg)
	e1:SetOperation(c31231302.spop)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31231302,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,31231202)
	e2:SetCondition(c31231302.drcon)
	e2:SetTarget(c31231302.drtg)
	e2:SetOperation(c31231302.drop)
	c:RegisterEffect(e2)
end
--filters
function c31231302.fcheck(c)
	return c:IsFaceup() and c:IsSetCard(0x3233)
end
--rearrange and spsummon
function c31231302.spcon(e,tp,eg,ep,ev,re,r,rp)
	local deck=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return deck:GetCount()>=3 and (g:GetCount()==0 or (g:GetCount()>0 and g:FilterCount(c31231302.fcheck,nil)==g:GetCount()))
end
function c31231302.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c31231302.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c31231302.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SortDecktop(tp,tp,3)
	Duel.BreakEffect()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--draw
function c31231302.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
function c31231302.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c31231302.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(g,nil,1,REASON_EFFECT)
	end
end
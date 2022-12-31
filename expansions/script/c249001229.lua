--Light-Crusader Arcane Tinkerer
function c249001229.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c249001229.spcon)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3040496,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,249001229)
	e2:SetCost(c249001229.thcost)
	e2:SetTarget(c249001229.thtg)
	e2:SetOperation(c249001229.thop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(249001229,ACTIVITY_SPSUMMON,c249001229.counterfilter)
end
function c249001229.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c249001229.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)>=2
end
function c249001229.filter(c)
	return c:IsSetCard(0x233) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function c249001229.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001229.filter,tp,LOCATION_HAND,0,1,nil) and Duel.GetCustomActivityCount(249001229,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001229.splimit)
	Duel.DiscardHand(tp,c249001229.filter,1,1,REASON_COST+REASON_DISCARD)
end
function c249001229.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
function c249001229.thfilter(c)
	return c:IsSetCard(0x233) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c249001229.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,4) end
end
function c249001229.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDiscardDeck(tp,4) then
		Duel.ConfirmDecktop(tp,4)
		local g=Duel.GetDecktopGroup(tp,4)
		if g:GetCount()>0 then
			Duel.DisableShuffleCheck()
			if g:IsExists(c249001229.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(3040496,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:FilterSelect(tp,c249001229.thfilter,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				Duel.ShuffleHand(tp)
				g:Sub(sg)
			end
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
		end
	end
end
--Dracosis Gallanth
function c39407.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72355272,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39407.rmcon)
	e1:SetOperation(c39407.rmop)
	c:RegisterEffect(e1)
	--battle indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e) return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) end)
	e4:SetValue(c39407.valcon)
	c:RegisterEffect(e4)
end
function c39407.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x300)
end
function c39407.sfilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER)
end
function c39407.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPosition(POS_FACEUP_ATTACK) then
		if Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterCount(c39407.sfilter,nil)==0
		or Duel.SelectYesNo(tp,aux.Stringid(39407,0)) then
			Duel.ChangePosition(c,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,c39407.sfilter,tp,LOCATION_HAND,0,1,1,nil,0x300)
			if g:FilterCount(function(c) return not c:IsPublic() end,nil)>0 then
				Duel.ConfirmCards(1-tp,g:Filter(function(c) return not c:IsPublic() end,nil))
			end
			Duel.SendtoDeck(g,nil,2,REASON_COST)
		end
	end
end
function c39407.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

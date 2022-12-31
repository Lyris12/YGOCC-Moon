--Galvanizer Battery
function c232002.initial_effect(c)
	local NoF=Effect.CreateEffect(c)
	NoF:SetType(EFFECT_TYPE_SINGLE)
	NoF:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	NoF:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	NoF:SetValue(function(e,c) if not c then return false end return not c:IsAttribute(ATTRIBUTE_LIGHT) end)
	c:RegisterEffect(NoF)
	local NoS=NoF:Clone()
	NoS:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(NoS)
	local NoX=NoF:Clone()
	NoX:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(NoX)
	local NoL=NoF:Clone()
	NoL:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(NoL)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(232002,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c232002.target)
	e1:SetOperation(c232002.operation)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

 --indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(c232002.bop)
	e4:SetCountLimit(c232002,1)
	c:RegisterEffect(e4)
end
function c232002.thfilter(c)
	return c:IsSetCard(0x232) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function c232002.bop(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c232002.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.MoveSequence(sg:GetFirst(),0)
			Duel.ConfirmCards(1-tp,sg)
			local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	end
end

function c232002.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c232002.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsSetCard(0x232) then
			Duel.BreakEffect()
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
		end
		Duel.ShuffleHand(tp)
	end
end
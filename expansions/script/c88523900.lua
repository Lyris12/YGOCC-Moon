--Kitseki Magmaer
--Script by XGlitchy30
function c88523900.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(c88523900.spcon)
	e1:SetTarget(c88523900.sptg)
	e1:SetOperation(c88523900.spop)
	c:RegisterEffect(e1)
	--synchro material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c88523900.effectcon)
	e2:SetTarget(c88523900.effecttg)
	e2:SetOperation(c88523900.effectop)
	c:RegisterEffect(e2)
end
--filters
function c88523900.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x215a) and c:IsAttribute(ATTRIBUTE_FIRE) and c:GetSummonPlayer()==tp
end
function c88523900.matfilter(c)
	return c:IsSetCard(0x215a) and c:IsAttribute(ATTRIBUTE_FIRE)
end
--spsummon
function c88523900.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88523900.cfilter,1,nil,tp)
end
function c88523900.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c88523900.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x47e0000)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
--synchro material
function c88523900.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function c88523900.effecttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chk==0 then return mg:IsExists(c88523900.matfilter,1,nil) end
end
function c88523900.effectop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	--Gain ATK
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(500)
	e0:SetReset(RESET_EVENT+0x1fe0000)
	sync:RegisterEffect(e0)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523900,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c88523900.drawtg)
	e1:SetOperation(c88523900.drawop)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	sync:RegisterEffect(e1)
end	
--Draw
function c88523900.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c88523900.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.IsPlayerCanDiscardDeck(1-tp,3) then
		if Duel.SelectYesNo(1-tp,aux.Stringid(88523886,1)) then
			Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
		else
			if Duel.Draw(p,2,REASON_EFFECT)==2 then
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
				Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
			end
		end
	else
		if Duel.Draw(p,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
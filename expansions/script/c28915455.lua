--Phantomb Lord's Vassal
local ref,id=GetID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,ref.matfilter,1,1,nil)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(2,id)
	--e1:SetCondition(ref.thcon)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	--Gain Ritual Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(ref.lvcon)
	e2:SetTarget(ref.lvtg)
	e2:SetOperation(ref.lvop)
	c:RegisterEffect(e2)
end

function ref.matfilter(c)
	return c:IsLinkSetCard(0x732) and not c:IsType(TYPE_LINK)
end

--Search
function ref.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function ref.thfilter(c)
	return c:IsCode(28915454) and c:IsAbleToHand()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return --Duel.GetReleaseGroupCount(tp,true)>0 and 
		Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	--local cg=Duel.GetReleaseGroup(tp,true):Select(tp,1,1,nil)
	--if #cg>0 and Duel.Release(cg,REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
		end
	--end
end

--Ritual Level
function ref.lvcfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function ref.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(ref.lvcfilter,1,nil,tp)
end
function ref.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ct=0
		if c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then ct=-1 end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
			and Duel.IsPlayerCanSpecialSummonMonster(tp,28915458,0,TYPES_TOKEN,0,0,nil,RACE_FAIRY,ATTRIBUTE_DARK)
	end --c:IsRelateToEffect(e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,7)
	Duel.SetTargetParam(lv)
end
function ref.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28915458,0,TYPES_TOKEN,0,0,0,RACE_FAIRY,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,28915458,0,0,0,lv)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				aux.CannotBeEDMaterial(token)
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				token:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end

		--[[local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)]]
	end
end

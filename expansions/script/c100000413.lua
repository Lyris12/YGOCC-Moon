--[[
Manaseal Warded Tome
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can either reveal 1 "Manaseal" monster from your hand or target 1 "Manaseal" monster from your GY or banishment; Special Summon that monster, and if you do, send cards from the top of your opponent's Deck to the GY, up to the number of face-up "Manaseal" cards you control.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,aux.DummyCost,s.sptg,s.spop)
	c:RegisterEffect(e1)    
	e1:SpecialSummonEventClone(c)
	--[[A "Manaseal" Synchro or Xyz Monster that was Synchro or Xyz Summoned using this card as material gains the following effect.
	● While there are 3 or more "Manaseal Word" Traps in your GY with different original names, this card cannot be targeted or destroyed by your opponent's card effects, also its ATK/DEF cannot be changed by your opponent's cards or effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end	
--E1
function s.rvfilter(c,e,tp)
	return not c:IsPublic() and c:IsSetCard(ARCHE_MANASEAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeEffectTarget(e) and c:IsSetCard(ARCHE_MANASEAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	local g=Duel.Group(s.spfilter,tp,LOCATION_GB,0,nil,e,tp)
	if e:IsCostChecked() then
		local hg=Duel.Group(s.rvfilter,tp,LOCATION_HAND,0,nil,e,tp)
		g:Merge(hg)
	end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and #g>0 and Duel.IsPlayerCanDiscardDeck(1-tp,1)
	end
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		e:SetProperty(EFFECT_FLAG_DELAY)
		Duel.ConfirmCards(1-tp,tc)
	else
		e:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	end
	Duel.SetTargetCard(tc)
	Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			if ct>1 then
				local max=Duel.GetDeckCount(1-tp)
				ct=Duel.AnnounceNumberMinMax(tp,1,math.min(ct,max))
			end
			Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
		end
	end
end

--E2
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_SYNCHRO|REASON_XYZ)>0 and e:GetHandler():GetReasonCard():IsSetCard(ARCHE_MANASEAL)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.econ)
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.econ)
	e2:SetValue(aux.indoval)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	local e3=Effect.CreateEffect(rc)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.imfilter)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e3,true)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_GLITCHY_CANNOT_CHANGE_DEF)
	rc:RegisterEffect(e4,true)
	aux.GainEffectType(rc,c)
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.efilter(c)
	return c:IsTrap() and c:IsSetCard(ARCHE_MANASEAL_WORD)
end
function s.econ(e)
	local ct=Duel.Group(s.efilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetOriginalCodeRule)
	return ct>=3
end
function s.imfilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() 
end
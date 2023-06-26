--Quarxis, Obbligato Primum
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	Marionightte.Induct(c,0)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Protect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(Marionightte.RewardCon(3))
	e3:SetTarget(ref.reptg)
	e3:SetValue(ref.repval)
	c:RegisterEffect(e3)
	--Bigbang Up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_BIGBANG_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FIEND+RACE_MACHINE))
	e4:SetValue(function(e,c,bc,mg) return 500,true end)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_BIGBANG_DEFENSE)
	c:RegisterEffect(e5)
end
ref.has_text_race=RACE_MACHINE+RACE_FIEND

--Search
function ref.thfilter(c,e,tp)
	return c:IsAbleToHand() and (c:IsCode(Marionightte.ID) or Marionightte.Is(c)) and not c:IsCode(id)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT,nil)
	end
end

--Protect
function ref.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_MATERIAL)) and c:IsCanChangePosition()
		and not (c:IsReason(REASON_REPLACE) and not c:IsReason(REASON_MATERIAL))
end
function ref.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and eg:IsExists(ref.repfilter,1,c,tp) end
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(ref.repfilter,c,tp)
		if sg:GetCount()>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		Duel.Hint(HINT_CARD,1-tp,c:GetOriginalCode())
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_REPLACE+REASON_DISCARD)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
function ref.repval(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end

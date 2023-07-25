--Brama, Divora, Elimina!
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_LIMIERRE)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.thfilter(c,e,tp)
	if not (c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa11) and c:IsAbleToHand()) then return false end
	if not e then return true end
	c:SetLocationAfterCost(LOCATION_HAND)
	local res=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	c:SetLocationAfterCost(0)
	return res
end
function s.disfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsDestructable(e)
end
function s.rvfilter(c,e,tp)
	if not (c:IsMonster() and c:IsRace(RACE_ZOMBIE) and not c:IsPublic()) then return false end
	if c:IsCode(CARD_LIMIERRE) then
		return Duel.IsExists(false,s.disfilter,tp,LOCATION_HAND,0,1,nil)
	elseif c:IsSetCard(0xa11) then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b=Duel.IsExists(false,s.rvfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return a or b end
	if b and e:GetHandler():AskPlayer(tp,STRING_ASK_REVEAL) then
		local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.ConfirmCards(1-tp,g)
		e:SetLabel(g:GetFirst():GetCode())
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	if not e:IsCostChecked() then
		e:SetLabel(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local lab=e:GetLabel()
	if lab>0 then
		if lab==CARD_LIMIERRE then
			e:SetCategory(CATEGORIES_SEARCH|CATEGORY_DESTROY)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
		else
			e:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		end
	else
		e:SetCategory(CATEGORIES_SEARCH)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lab=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) and lab>0 then
		Duel.ShuffleHand(tp)
		if lab==CARD_LIMIERRE then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil,e)
			if #dg>0 then
				local rc=dg:GetFirst()
				rc:RegisterFlagEffect(CARD_LIMIERRE,RESET_CHAIN,0,1)
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
				rc:ResetFlagEffect(CARD_LIMIERRE)
			end
		else
			if Duel.GetMZoneCount(tp)<=0 or not g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.repfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsCode(CARD_LIMIERRE) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
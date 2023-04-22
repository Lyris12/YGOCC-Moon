--Driven Crazy
--Drive in Folle
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 face-up card your opponent controls; banish your Engaged monster, and if you do, negate the effects of the targeted card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If your opponent Special Summons a monster(s) from their Extra Deck, while this card is in your GY (except during the Damage Step):
	You can Set this card (but banish it when it leaves the field), and if you do, you can add 1 of your banished Drive Monsters to your hand, and if you do that, you can Engage it.]]
	local GYCheck=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(GYCheck)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--You can activate this card from your hand if you Engaged a monster during that turn.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ENGAGE)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_END,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	local ec=Duel.GetEngagedCard(tp)
	if chk==0 then return ec and ec:IsAbleToRemove() and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(ec,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=Duel.GetEngagedCard(tp)
	if ec and Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) then
			Duel.Negate(tc,e)
		end
	end
end

function s.cfilter(c,tp,se)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp) and (se==nil or c:GetReasonEffect()~=se)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_BANISH_REDIRECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
		if c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) and c:AskPlayer(tp,2) then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
			if #g>0 then
				Duel.SearchAndEngage(g:GetFirst(),e,tp)
			end
		end
	end
end

function s.handcon(e)
	return Duel.PlayerHasFlagEffect(e:GetHandlerPlayer(),id)
end
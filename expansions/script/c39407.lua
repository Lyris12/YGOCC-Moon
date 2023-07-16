--Dracosis Gallanth
local s,id=GetID()
function s.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.rmcon)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--battle indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) end)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	if not aux.DracosisTriggeringSetcodeCheck then
		aux.DracosisTriggeringSetcodeCheck=true
		aux.DracosisTriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		if rc:IsSetCard(0x300) then
			aux.DracosisTriggeringSetcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(0x300) then
			aux.DracosisTriggeringSetcode[cid]=true
			return
		end
	end
	aux.DracosisTriggeringSetcode[cid]=false
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return aux.DracosisTriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return aux.DracosisTriggeringSetcode[cid]==true
		
	else
		return rc:IsSetCard(0x300)
	end
end
function s.sfilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPosition(POS_FACEUP_ATTACK) then
		Duel.HintSelection(Group.FromCards(c))
		local g=Duel.Group(s.sfilter,tp,LOCATION_HAND,0,nil)
		if #g==0 or not c:AskPlayer(tp,STRING_ASK_SHUFFLE_INTO_DECK) then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.ChangePosition(c,POS_FACEUP_ATTACK)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Hint(HINT_CARD,tp,id)
				Duel.ConfirmCards(1-tp,sg)
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end

function s.valcon(e,re,r,rp)
	return r&REASON_BATTLE~=0
end

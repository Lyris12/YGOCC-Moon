--Ergoriesumante Eve Nincodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--chain
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
	c:SPSummonCounter(s.counterfilter)
end
s.expired_names={}
--FILTERS
function s.counterfilter(c)
	return not c:IsType(TYPE_LINK) or c:IsSetCard(0xca4)
end
function s.scf(c)
	return c:IsCode(1011) and c:IsAbleToHand()
end
function s.matf(c)
	return c:IsRace(RACE_CYBERSE+RACE_FIEND)
end
--
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,0) and aux.SPSummonRestr(false,s.counterfilter)(e,tp,eg,ep,ev,re,r,rp,0) end
	aux.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,1)
	aux.SPSummonRestr(false,s.counterfilter)(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scf,tp,LOCATION_DECK,0,1,nil) end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	if #s.expired_names>0 then
		for _,name in ipairs(s.expired_names) do
			table.insert(getmetatable(e:GetHandler()).announce_filter,name)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_ISCODE)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_AND)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_NOT)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	table.insert(s.expired_names,ac)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	aux.Search(s.scf,1,1)(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetTargetParam()
	--extra materials
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
	e1:SetLabel(1,code)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.mttg)
	e1:SetValue(s.mtval_link)
	e1:SetOperation(s.mtop_link)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	e2:SetLabel(2,code)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.mttg)
	e2:SetValue(s.mtval)
	e2:SetOperation(s.mtop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.mttg(e,c)
	local _,code=e:GetLabel()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) and c:IsCode(code) and c:IsAbleToDeck()
end
function s.mtval_link(e,lc,mg,c,tp)
	if not lc then return false, 1 end
	return true, 1
end
function s.mtval(e,c,tp,mg)
	if not c then return false, 1 end
	return true, 1
end
function s.mtop_link(g)
	return Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_MATERIAL+REASON_LINK)
end
function s.mtop(g)
	return Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	table.insert(s.expired_names,ac)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return false end
	local code=Duel.GetTargetParam()
	local b1=c:IsFaceup()
	local b2=c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_DECK,0,1,nil,code)
	local opt
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,5))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,6))+1
	end
	if opt==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN+RESET_DISABLE)
		c:RegisterEffect(e1)
		if re then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_GLITCHY_HACK_CODE)
			e1:SetTargetRange(0xff,0xff)
			e1:SetLabelObject(re)
			e1:SetValue(code)
			e1:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e1,tp)
		end
	elseif opt==1 then
		if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and aux.PLChk(c,nil,LOCATION_HAND) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thf,tp,LOCATION_DECK,0,1,1,nil,code)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
function s.thf(c,code)
	return aux.IsCodeListed(c,code) and c:IsAbleToHand()
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
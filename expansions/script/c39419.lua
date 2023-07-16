--Dracosis Mystrade
--Dracosi Mystrade
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x300),2)
	--[[You can treat Level 6 "Dracosis" monsters as Link-2 Link Monsters for the Link Summon of this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MULTIPLE_LMATERIAL)
	e1:SetTarget(s.lktg)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	--[[Each time a "Dracosis" monster(s) this card points to activates its effect, this card gains 100 ATK immediately after it resolves.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--[[If this card would be destroyed by battle or card effect, or banished, you can destroy 1 of your monsters this card points to instead.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.desreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(s.rmreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e5)
	if not s.TriggeringSetcodeCheck then
		s.TriggeringSetcodeCheck=true
		s.TriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_CREATED)
		ge1:SetOperation(s.chreg)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.chreg(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsSetCard(0x300) then
		s.TriggeringSetcode[cid]=true
		return
	end
	s.TriggeringSetcode[cid]=false
end

--E1
function s.lktg(e,c)
	return c:IsLinkType(TYPE_MONSTER) and c:IsLinkSetCard(0x300) and c:IsLevel(6)
end

--E2+E3
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not re:IsActiveType(TYPE_MONSTER) or not rc then return end
	local cid,loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then seq=seq+16 end
	local c=e:GetHandler()
	if s.TriggeringSetcode[cid] and loc&LOCATION_MZONE~=0 and bit.extract(c:GetLinkedZone(),seq)~=0 then
		c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&(~RESET_TURN_SET))|RESET_CHAIN,0,1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffect(id)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:UpdateATK(100,true,c)
	end
end

--FE4
function s.repfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
--E4
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetLinkedGroup()
		return #g>0 and not c:IsReason(REASON_REPLACE) and g:IsExists(s.repfilter,1,nil,e,tp)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetLinkedGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.repfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else
		return false
	end
end
function s.rmreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetLinkedGroup()
		return #g>0 and c:IsReason(REASON_EFFECT) and c:GetDestination()==LOCATION_REMOVED and g:IsExists(s.repfilter,1,nil,e,tp)
	end
	if c:AskPlayer(tp,0) then
		local g=c:GetLinkedGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.repfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else
		return false
	end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT|REASON_REPLACE)
end
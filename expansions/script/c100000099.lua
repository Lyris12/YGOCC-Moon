--Rescue Trappit
--Trappolaniglio da Soccorso
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step):
	Set 2 "Trappit" cards from your Deck to your field, but banish them when they leave the field, also, until the end of the turn, you can activate 1 Trap the turn it was Set.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card, then target 1 other "Trappit" card you control, even if Set;
	banish it, and if you do, Set that banished card to your field at the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(aux.TurnPlayerCond(0))
	c:RegisterEffect(e3)
end
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end

--Filters E1
function s.setfilter(c,e,tp)
	if not c:IsSetCard(ARCHE_TRAPPIT) or c:IsCode(id) then return false end
	return c:IsCanBeSet(e,tp,true,true)
end
function s.gcheck(g,c,G,f,min,max,ext_params)
	local mmz,stz=table.unpack(ext_params)
	return mmz>=g:FilterCount(Card.IsMonster,nil) and (stz>=g:FilterCount(s.notfield,nil) and g:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1)
end
function s.notfield(c)
	return c:IsST() and not c:IsType(TYPE_FIELD)
end
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mmz,stz=Duel.GetMZoneCount(tp),Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsInBackrow() then
			stz=stz-1
		end
		local g=Duel.Group(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
		aux.GCheckAdditional=s.gcheck
		local res=g:CheckSubGroup(aux.TRUE,2,2,mmz,stz)
		aux.GCheckAdditional=nil
		return res
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mmz,stz=Duel.GetMZoneCount(tp),Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.Group(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
	aux.GCheckAdditional=s.gcheck
	local res=g:SelectSubGroup(tp,aux.TRUE,false,2,2,mmz,stz)
	aux.GCheckAdditional=nil
	if #res>0 and Duel.Set(tp,res)>0 then
		local og=res:Filter(Card.IsOnField,nil)
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_BANISH_REDIRECT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1,true)
		end
	end
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1,id)
	Duel.RegisterEffect(e2,tp)
end

--Filters E2
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToRemove()
end
--Text sections E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Banish(tc)>0 and tc:IsBanished() then
		local fid=e:GetFieldID()
		tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE,1,fid,aux.Stringid(id,4))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(5)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.setcon)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:HasFlagEffectLabel(id+100,e:GetLabel()) then
		e:Reset()
		return false
	else
		return true
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:HasFlagEffectLabel(id+100,e:GetLabel()) and tc:IsCanBeSet(e,tp) then
		Duel.Set(tp,tc)
	end
end
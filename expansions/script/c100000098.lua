--Trappitech Bunny Decoy Bundle
--Trappolanigliotech Pacchetto di Esche Coniglietto
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	--[[You can also use Set "Trappit" Traps in your Spell & Trap Zones as material for this card's Link Summon.]]
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_FIELD)
	ex:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	ex:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	ex:SetRange(LOCATION_EXTRA)
	ex:SetTargetRange(LOCATION_SZONE,0)
	ex:SetTarget(s.mattg)
	ex:SetValue(s.matval)
	c:RegisterEffect(ex)
	--[[Cannot be used as Link Material, except for the Link Summon of a "Trappit" monster.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(s.lkval)
	c:RegisterEffect(e0)
	--[[If this card is Link Summoned, and there is a "Trappit" monster(s) on your field, or in your GY:
	You can Set directly from your Deck, 1 Trap that activates when a monster is Normal or Flip Summoned, or Normal Set, but with a different name from the Traps in your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(aux.LinkSummonedCond)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--[[If a "Trappit" card(s) you control (even if Set) would be destroyed, or banished, by an opponent's card effect, you can banish this card from your GY instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2x:SetCode(EFFECT_SEND_REPLACE)
	e2x:SetRange(LOCATION_GRAVE)
	e2x:SHOPT()
	e2x:SetTarget(s.reptg_banish)
	e2x:SetValue(s.repval)
	e2x:SetOperation(s.repop)
	c:RegisterEffect(e2x)
end
--EX
function s.matfilter(c)
	if c:IsInBackrow() then
		return c:IsFacedown() and c:IsLinkSetCard(ARCHE_TRAPPIT) and c:IsLinkType(TYPE_TRAP)
	elseif c:IsLocation(LOCATION_MZONE) then
		return c:IsSummonType(SUMMON_TYPE_NORMAL)
	end
	return false
end
function s.mattg(e,c)
	return c:IsFacedown() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsTrap()
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,true
end

--E0
function s.lkval(e,c)
	if not c then return false end
	return not c:IsSetCard(ARCHE_TRAPPIT)
end

--FILTERS E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_TRAPPIT)
end
function s.setfilter(c,tp)
	local codes={c:GetCode()}
	if not c:IsNormalTrap() or not c:IsSSetable() or Duel.IsExistingMatchingCard(s.excfilter,tp,LOCATION_GRAVE,0,1,c,codes) then return false end
	local egroup=c:GetEffects()
	local res=false
	for i,e in ipairs(egroup) do
		if e and not e:WasReset(c) then
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
				local event=e:GetCode()
				if (event==EVENT_SUMMON_SUCCESS or event==EVENT_FLIP_SUMMON_SUCCESS) or e:IsHasCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET) then
					res=true
					break
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.excfilter(c,codes)
	return c:IsTrap() and c:IsCode(table.unpack(codes))
end
--E1
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

--FILTERS E2
function s.repfilter(c,tp,banish)
	if banish and c:GetDestination()&LOCATION_REMOVED==0 then return false end
	return c:IsControler(tp) and c:IsOnField() and c:IsSetCard(ARCHE_TRAPPIT) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()~=tp and c:GetReasonPlayer()~=PLAYER_NONE
end
--E2
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,c,tp) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(s.repfilter,c,tp)
		if #sg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53167658,0))
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		local g=sg:Filter(aux.AND(Card.IsOnField,Card.IsFacedown),nil)
		if #g>0 then
			Duel.ConfirmCards(1-tp,g)
		end
		return true
	else
		return false
	end
end
function s.reptg_banish(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,c,tp,true) end
	if c:AskPlayer(tp,1) then
		local sg=eg:Filter(s.repfilter,c,tp,true)
		if #sg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			sg=sg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		local g=sg:Filter(aux.AND(Card.IsOnField,Card.IsFacedown),nil)
		if #g>0 then
			Duel.ConfirmCards(1-tp,g)
		end
		return true
	else
		return false
	end
end
function s.repval(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end
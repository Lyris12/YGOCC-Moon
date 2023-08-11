--Trappit Excavator
--Trappolaniglio Scavatore
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is Normal or Flip Summoned:
	You can take 1 "Trappit" Spell/Trap from your Deck, and either add it to your hand, or Set it to your field. If you Set it, and it is a Trap, it can be activated this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e1x=e1:FlipSummonEventClone(c)
	--[[You can reveal 1 "Trappit" monster, or 1 Normal Trap, in your hand; immediately after this effect resolves, apply 1 of these effects.
	● Normal Summon 1 monster, and if you do, it loses 1000 ATK/DEF.
	● Your opponent Normal Summons 1 monster, and if they do, it gains 1000 ATK/DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_SUMMON|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.nscost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop(0))
	c:RegisterEffect(e2)
end

function s.filter(c)
	return c:IsST() and c:IsSetCard(ARCHE_TRAPPIT) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToHand()
		local b2=tc:IsSSetable()
		local opt=aux.Option(tp,false,false,{b1,STRING_ADD_TO_HAND},{b2,STRING_SET})
		if opt==0 then
			Duel.Search(tc,tp)
		else
			if Duel.SSet(tp,tc)>0 and tc:IsTrap() and tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown() then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(STRING_FAST_ACTIVATION)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

function s.costfilter(c)
	return (c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) or c:IsNormalTrap()) and not c:IsPublic()
end
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,PLAYER_ALL,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local hg=Duel.GetHand(1-tp)
					local b1 = Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil)
					local b2 = Duel.IsPlayerCanDraw(1-tp)
					local opt = aux.Option(tp,id,2,b1,b2)
					if opt==0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
						local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,true,nil)
						local tc=g:GetFirst()
						if tc then
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
							e1:SetCode(EVENT_SUMMON_SUCCESS)
							e1:SetLabelObject(tc)
							e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
								s.nsop(1)(e,tp,eg,ep,ev,re,r,rp,_e,-1000)
								_e:Reset()
							end
							)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
							tc:RegisterEffect(e1,true)
							Duel.Summon(tp,tc,true,nil)
						end
					
					elseif opt==1 then
						Duel.Draw(1-tp,1,REASON_EFFECT)
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EVENT_CHAIN_SOLVED)
						e1:SetLabelObject(e)
						e1:SetOperation(s.nsop(2))
						e1:SetOwnerPlayer(1-tp)
						Duel.RegisterEffect(e1,1-tp)
					end
				end
				
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce,stat)
					local tc=ce:GetLabelObject()
					if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
						tc:UpdateATKDEF(stat,stat,true,ce:GetOwner())
					end
				end
				
	elseif mode==2 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if re~=e:GetLabelObject() then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,true,nil)
					local tc=g:GetFirst()
					if tc then
						local e1=Effect.CreateEffect(e:GetOwner())
						e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EVENT_SUMMON_SUCCESS)
						e1:SetLabelObject(tc)
						e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
							s.nsop(1)(e,tp,eg,ep,ev,re,r,rp,_e,1000)
							_e:Reset()
						end
						)
						e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
						tc:RegisterEffect(e1,true)
						Duel.Summon(tp,tc,true,nil)
					end
					e:Reset()
				end
	end
end
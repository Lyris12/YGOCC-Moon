--Trappit Overseer
--Trappolaniglio Supervisore
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id=GetID()
function s.initial_effect(c)
	--[[You can target 1 Set "Trappit" monster you control; change it to face-up Attack Position (this is treated as a Flip Summon),
	also, during your Main Phase this turn, you can Normal Summon/Set 1 monster this turn in addition to your Normal Summon/Set (You can only gain this effect once per turn).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[You can reveal 1 "Trappit" monster, or 1 Normal Trap, in your hand; immediately after this effect resolves, apply 1 of these effects.
	● Normal Summon 1 monster, and if you do, its effects cannot be negated.
	● Your opponent Normal Summons 1 monster, but its effects are negated.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_SUMMON|CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.nscost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop(0))
	c:RegisterEffect(e2)
end

function s.filter(c,tp)
	return c:IsFacedown() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsCanBeFlipSummoned(tp,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	Duel.Select(HINTMSG_FACEDOWN,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFacedown() then
		Duel.FlipSummon(tp,tc)
	end
	if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and not Duel.PlayerHasFlagEffect(tp,id) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(4)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SET_COUNT)
		Duel.RegisterEffect(e2,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
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
								s.nsop(1)(e,tp,eg,ep,ev,re,r,rp,_e)
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
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					local tc=ce:GetLabelObject()
					if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
						local c=e:GetHandler()
						local e2=Effect.CreateEffect(c)
						e2:SetDescription(STRING_EFFECTS_CANNOT_BE_NEGATED)
						e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetCode(EFFECT_CANNOT_DISABLE)
						e2:SetReset(RESET_EVENT|RESETS_STANDARD)
						tc:RegisterEffect(e2)
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_FIELD)
						e3:SetCode(EFFECT_CANNOT_DISEFFECT)
						e3:SetRange(LOCATION_MZONE)
						e3:SetValue(s.efilter)
						e3:SetReset(RESET_EVENT|RESETS_STANDARD)
						tc:RegisterEffect(e3)
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
							s.nsop(3)(e,tp,eg,ep,ev,re,r,rp,_e)
							_e:Reset()
						end
						)
						e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
						tc:RegisterEffect(e1,true)
						Duel.Summon(tp,tc,true,nil)
					end
					e:Reset()
				end
				
	elseif mode==3 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					local tc=ce:GetLabelObject()
					if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
						Duel.Negate(tc,e)
					end
				end
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end